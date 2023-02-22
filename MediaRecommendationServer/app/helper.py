''' Helper functions for extracting data and throw away testing.
'''

import sys
import os
import django
from django.conf import settings

import re
import http.client
import time
import xmltodict
import json
import pandas as pd
import numpy as np
import requests
import time

DATA_PATH = '../Data/ml-25m/'
BOOK_PATH = '../Data/books/'

def save_movie_row(row, batch_links, all_genres):
    '''Extracts the movie features from row with corresponding batch_links and 
       adds the movie to each of it's genres within all_genres. 
       Returns the movie object.
    '''
    df_to_numpy = {'movieId': 0, 'title': 1, 'genres': 2}

    movielens_id = row[df_to_numpy['movieId']]
    # Extract year from title - if no year we'll just ignore 
    year_str = row[df_to_numpy['title']].split()[-1]
    if not len(year_str) >= 6 or not (year_str[-6] == '(' and year_str[-1] == ')' and year_str[-5:-1].isnumeric()):
        print('Issue with year for movie: {} {}, as {}'.format(row[df_to_numpy['title']], movielens_id, year_str[-5:-1]))
        return
    year = int(year_str[-5:-1])
    title = ' '.join(row[df_to_numpy['title']].split()[:-1])
    genres = row[df_to_numpy['genres']].split('|')

    # Handle links
    links = batch_links[batch_links['movieId'] == movielens_id]
    if not len(links) == 1:
        print('Issue with links for movie: {} {}'.format(title, movielens_id))
        return
    imdb_id = links['imdbId'].iloc[0]
    tmdb_id = links['tmdbId'].iloc[0] if not np.isnan(links['tmdbId'].iloc[0]) else -1

    average_rating = 0
    num_watched = 0

    movie = Movie(title=title, genres=genres, year=year, 
                imdb_id=imdb_id, tmdb_id=tmdb_id, 
                average_rating=average_rating, 
                num_watched=num_watched, 
                movielens_id=movielens_id)

    for genre in genres:
        if genre in all_genres:
            all_genres[genre].append(movie)
        else:
            all_genres[genre] = [movie]

    return movie


def import_movies():
    '''Imports movieLens Movies.
    '''
    BATCH_SIZE = 5000

    df_movies = pd.read_csv(DATA_PATH + 'movies.csv', chunksize=BATCH_SIZE)
    df_links = pd.read_csv(DATA_PATH + 'links.csv')

    i = 1
    all_genres = {}
    while True:
        try:
            df_moviebatch = df_movies.get_chunk()

            moviebatch = df_moviebatch.to_numpy()
            movies = []
            for x in moviebatch:
                movie = save_movie_row(x, df_links, all_genres)
                if movie:
                    movies.append(movie)
            Movie.objects.bulk_create(movies)

            print(i*5000)
            i+=1
            
        except Exception as e: 
            print(e)
            break

    for genre, genre_movies in all_genres.items():
        movie_genre = MovieGenre(name=genre)
        movie_genre.save()
        movie_genre.movies.add(*genre_movies)
        movie_genre.count = len(genre_movies)
        movie_genre.save()
    

def import_movie_rating_stats():
    """ Computes and updates movie rating stats.
    """
    print('Computing stats ...')
    BATCH_SIZE = 250000
    df_ratings = pd.read_csv(DATA_PATH + 'ratings.csv', chunksize=BATCH_SIZE)
    movie_stats = {}
    n_batch = 0
    while True:
        try:
            df_batch = df_ratings.get_chunk()

            # Update stats for each movie in batch
            unique_ids = np.unique(df_batch['movieId'])
            for id in unique_ids:
                avg, count = movie_stats[id] if id in movie_stats else (0,0)
                avg *= count

                movie_ratings = df_batch[df_batch['movieId'] == id]['rating']
                avg += np.sum(movie_ratings)
                count += len(movie_ratings)
                avg /= count

                assert avg >= 0 and avg <= 5 and count > 0, 'Movie {} has avg {} with count {}'.format(id, avg, count)
                movie_stats[id] = (avg, count)
            n_batch += 1
            print(n_batch)
            
        except Exception as e: 
            print('ERROR while computing stats: {}'.format(e))
            break
    
    print('{} batches of size {}'.format(n_batch, BATCH_SIZE))
    print('Computed stats for {} movies'.format(len(movie_stats)))

    # Add stats to movies
    movies = Movie.objects.all()
    print('Adding stats to movies ...')
    n_updated_movies = 0
    for movie in movies:
        if movie.movielens_id in movie_stats:
            avg, count = movie_stats[movie.movielens_id]
            movie.average_rating = avg
            movie.num_watched = count
            n_updated_movies += 1
    print('Added stats to {} movies'.format(n_updated_movies))

    print('Updating ...')
    # Update in PostgreSQL
    Movie.objects.bulk_update(movies, ['average_rating', 'num_watched'])
    print('Done')


def import_movie_images():
    """ Imports the movie image links and movie Series from TMDB.
    """
    movies = Movie.objects.all()
    all_series = {}
    print('Pulling image URLs and series from TMDB ...')
    for i, movie in enumerate(movies):
        url = "https://api.themoviedb.org/3/movie/{}?language=en-US&api_key=60d78c7cfee3c407c714903efd4c3359".format(movie.tmdb_id)
        r = requests.get(url)
        r_json = r.json()

        if r.status_code != 200:
            print('Movie {} {} Error: Status {}.'.format(movie.id, movie.title, r.status_code))
            continue
        
        if 'poster_path' not in r_json:
            print('Movie {} {}: No "poster_path"'.format(movie.id, movie.title))
        else:
            movie.image_url = 'https://image.tmdb.org/t/p/w342{}'.format(r.json()['poster_path'])

        if 'belongs_to_collection' in r_json and r_json['belongs_to_collection']:
            series_id = int(r_json['belongs_to_collection']['id'])
            series_title = r_json['belongs_to_collection']['name']
            if series_id in all_series:
                all_series[series_id]['movies'].append(movie)
            else:
                all_series[series_id] = {'title': series_title, 'movies': [movie]}

    print('Updating Movie images ...')
    # Update in PostgreSQL
    Movie.objects.bulk_update(movies, ['image_url'], batch_size=10000)

    print('Creating Movie series ...')
    # Create in PostgreSQL
    series_objs = []
    for id, series in all_series.items():
        series_objs.append(MovieSeries(tmdb_id=id, name=series['title'], avg_rating=0.0))
    MovieSeries.objects.bulk_create(series_objs)
    
    print('Updating Movie series movies, most viewed, and avg rating ...')
    for series in series_objs:
        series_movies = all_series[series.tmdb_id]['movies']
        series.movies.add(*series_movies)
        
        avg_sum = 0.0
        most_viewed = series_movies[0]
        for movie in series_movies:
            avg_sum += movie.average_rating
            if most_viewed.average_rating < movie.average_rating:
                most_viewed = movie
        series.avg_rating = avg_sum / len(series_movies)
        series.most_viewed = most_viewed
    
    MovieSeries.objects.bulk_update(series_objs, ['avg_rating', 'most_viewed'])
    print('Done')



def import_books():
    BATCH_SIZE = 50000
    authors_df = pd.read_json(BOOK_PATH + 'goodreads_book_authors.json', lines=True)
    series_df = pd.read_json(BOOK_PATH + 'goodreads_book_series.json', lines=True)
    idmap_df = pd.read_csv(BOOK_PATH + 'book_id_map.csv')

    print('Importing Books ...')
    all_books, all_genres, all_series = {}, {}, {}
    i = 0
    extra_versions = 0
    with pd.read_json(BOOK_PATH + 'goodreads_books.json', 
                      lines=True, 
                      chunksize=BATCH_SIZE
                      ) as reader:
        for chunk in reader:
            i += 1
            # Remove non-english books
            chunk = chunk[chunk['language_code'].str.fullmatch('') \
                          | chunk['language_code'].str.contains('en', case=False)]

            for _, x in chunk.iterrows():
                # Convert small image url from medium url
                if 'nophoto' in x['image_url']:
                    small_img_url = x['image_url']
                else:
                    split_url = x['image_url'].split('/')
                    try:
                        if split_url[-2][-1] == 'm':
                            split_url[-2] = split_url[-2][:-1] + 's'
                            small_img_url = '/'.join(split_url)
                        else:
                            small_img_url = x['image_url']
                    except:
                        small_img_url = x['image_url']
                
                # Clean up genres a little
                genres = []
                for genre in x['popular_shelves']:
                    if int(genre['count']) <= 50: continue
                    next_genre = False
                    for name in ['read', 'own', 'finish', 'library', 'have', 
                                 'wish', 'default', 'buy', 'borrow']:
                        if name in genre['name']:
                            next_genre = True
                            break
                    if next_genre: continue
                    genres.append(genre['name'])

                # Map author ids to name from author_df
                author_names = ''
                n_authors = len(x['authors']) if len(x['authors']) < 4 else 4
                for author_id in x['authors'][:n_authors]:
                    author = authors_df[authors_df['author_id'] == int(author_id['author_id'])]
                    if len(author) == 1:
                        author_names += author['name'].iloc[0] + ', '
                if len(author_names) == 0 or len(author_names) >= 200:
                    continue
                # Remove ending comma
                author_names = author_names[:-2]

                if not x['description'] or not x['publication_year']:
                    continue

                # Ignore if not as popular as the version already saved
                old_goodreadsid, old_n_ratings = None, 0
                if x['work_id'] in all_books:
                    extra_versions += 1
                    if int(x['ratings_count']) < all_books[x['work_id']].num_watched:
                        # Add version ratings
                        all_books[x['work_id']].num_watched += int(x['ratings_count'])
                        continue
                    else:
                        old_goodreadsid = all_books[x['work_id']].goodreads_id
                        old_n_ratings = all_books[x['work_id']].num_watched

                # Add any other version ratings
                ratings_count = int(x['ratings_count']) + old_n_ratings

                book = Book(title=x['title_without_series'],
                            author=author_names,
                            description=x['description'],
                            num_pages=int(x['num_pages']) if x['num_pages'] else 0,
                            publisher=x['publisher'],
                            year=int(x['publication_year']),
                            genres=genres,
                            goodreads_id=x['book_id'],
                            num_watched=ratings_count,
                            average_rating=float(x['average_rating']),
                            image_url=x['image_url'],
                            work_id=x['work_id'],
                            small_image_url=small_img_url)
                
                all_books[x['work_id']] = book

                # Add book to genre
                for genre in genres:
                    if genre in all_genres:
                        all_genres[genre][x['work_id']] = book
                    else:
                        all_genres[genre] = {x['work_id']: book}

                # Add book to series
                if x['series']:
                    for series_id in x['series']:
                        series = series_df[series_df['series_id'] == int(series_id)]
                        if len(series) > 0:
                            series_title = series['title'].iloc[0]

                            if series_title in all_series:
                                all_series[series_title]['books'][x['work_id']] = book
                            else:
                                all_series[series_title] = {'id': int(series_id),
                                                            'books': { x['work_id']: book }}
                        
                # Replace all occurrences of old_goodreadsid in ratings_map with new
                if old_goodreadsid:
                    idmap_df.loc[idmap_df['book_id'] == old_goodreadsid, 'book_id'] = x['book_id']

            if i % 5 == 0:
                print('... {} batches completed'.format(i))

    print('... Extra versions count {}'.format(extra_versions))
    print('... Saving Books to DB ...')
    Book.objects.bulk_create(list(all_books.values()), batch_size=BATCH_SIZE)
    
    # Save new map
    print('Removing rating map ids that arent in DB ...')
    all_goodreads_ids = list(Book.objects.all().values_list('goodreads_id', flat=True))
    print('... Dropping {} ids'.format(
        len(idmap_df[~idmap_df['book_id'].isin(all_goodreads_ids)]))
        )
    idmap_df = idmap_df[idmap_df['book_id'].isin(all_goodreads_ids)]
    # idmap_df.to_csv(BOOK_PATH + 'book_id_map-dedup-test2.csv')
    idmap_df.to_csv(BOOK_PATH + 'book_id_map-dedup-v1.csv')

    # Genres
    print('Creating Book genres ...')
    print('... Removing bad versions from Genres ...')
    n_bad_versions = __clean_bad_versions_from_bookgenres(all_genres, all_books)
    print('...... {} bad works'.format(n_bad_versions))
    print('... Creating {} Genres ...'.format(len(all_genres)))
    __create_book_genres(all_genres)

    # Series
    print('Creating Book series ...')
    print('... Removing bad versions from Series ...')
    n_bad_versions, n_del_series = __clean_bad_versions_from_bookseries(all_series, all_books)
    print('...... {} bad works and {} empty series after'.format(
        n_bad_versions, n_del_series
    ))
    print('... Creating {} Series ...'.format(len(all_series)))
    series_objs = __create_bookseries(all_series, BATCH_SIZE)
    print('... Updating Book series books, most viewed, and avg rating ...')
    __update_bookseries(series_objs, all_series, BATCH_SIZE)


def __clean_bad_versions_from_bookgenres(all_genres, all_books):
    '''
    '''
    n_bad_versions = 0
    for genre, genre_workid_books in all_genres.items():
        del_works = []
        for work_id, book in genre_workid_books.items():
            if work_id not in all_books or book.id != all_books[work_id].id:
                del_works.append(work_id)

        n_bad_versions += len(del_works)
        for work_id in del_works:
            del genre_workid_books[work_id]
    return n_bad_versions

def __create_book_genres(all_genres):
    '''
    '''
    for genre, genre_workid_books in all_genres.items():
        # Ignore any low count genres
        if len(genre_workid_books) < 50:
            continue
        book_objs = list(genre_workid_books.values())
        
        book_genre = BookGenre(name=genre)
        book_genre.save()
        book_genre.books.add(*book_objs)
        book_genre.count = len(book_objs)
        book_genre.save()

def __clean_bad_versions_from_bookseries(all_series, all_books):
    '''
    '''
    n_bad_versions = 0
    del_series = []
    for title, series in all_series.items():
        del_works = []
        for work_id, book in series['books'].items():
            if work_id not in all_books or book.id != all_books[work_id].id:
                del_works.append(work_id)

        n_bad_versions += len(del_works)
        for work_id in del_works:
            del series['books'][work_id]
        if len(series['books']) <= 1:
            del_series.append(title)

    # Remove any empty Series
    for title in del_series:
        del all_series[title]
    
    return n_bad_versions, len(del_series)

def __create_bookseries(all_series, batch_size):
    '''
    '''
    series_objs = []
    for title, series in all_series.items():
        series_objs.append(BookSeries(goodreads_id=series['id'], name=title, avg_rating=0.0))
    BookSeries.objects.bulk_create(series_objs, batch_size=batch_size)
    return series_objs

def __update_bookseries(series_objs, all_series, batch_size):
    '''
    '''
    for series in series_objs:
        series_books = list(all_series[series.name]['books'].values())
        series.books.add(*series_books)
        
        avg_sum = 0.0
        most_viewed = series_books[0]
        for book in series_books:
            avg_sum += float(book.average_rating)
            if most_viewed.num_watched < float(book.num_watched):
                most_viewed = book
        series.avg_rating = avg_sum / len(series_books)
        series.most_viewed = most_viewed
        # assert series.avg_rating >= 0 and series.avg_rating <= 5
    
    BookSeries.objects.bulk_update(series_objs, ['avg_rating', 'most_viewed'], batch_size=batch_size)


def remove_book_ratings_notin_django():
    ''' Removes interactions not in the deduplicated book_id_map 
        (any books not in Django).
    '''
    BATCH_SIZE = 1000000
    idmap_df = pd.read_csv(BOOK_PATH + 'book_id_map-dedup-v1.csv')
    book_ids = list(idmap_df['book_id_csv'])
    output_path = BOOK_PATH + 'goodreads_interactions-clean.csv'
    n_interactions = 0

    with pd.read_csv(BOOK_PATH + 'goodreads_interactions.csv', chunksize=BATCH_SIZE) as reader:
        for chunk in reader:
            new_chunk = chunk[chunk['book_id'].isin(book_ids)]
            n_interactions += len(new_chunk)
            new_chunk.to_csv(output_path, mode='a', header=not os.path.exists(output_path))
    
    print('Total interactions after cleaning {}'.format(n_interactions))

def add_book_features_to_ratings():
    ''' Pulls average_rating, num_watched, and genres from Django, 
        adds them to book_id_map, and saves the updated pd.Dataframe.
    '''
    idmap_df = pd.read_csv(BOOK_PATH + 'book_id_map-dedup-v1.csv')
    idmap_df['avg_rating'] = None
    idmap_df['num_watched'] = None
    idmap_df['genres'] = None
    genre_books = set(BookGenre.objects.values_list('name'))

    start = time.time()
    all_feats, all_genres, indexes = [], [], []

    for i, book in enumerate(Book.objects.values(
        'goodreads_id','average_rating','num_watched','genres'
        )):
        # Remove genres that were cleaned from BookGenre.objects but left on the Book
        book_genres = [name for name in book['genres'] if (name,) in genre_books]

        new_indexes = idmap_df.index[idmap_df['book_id'] == book['goodreads_id']]
        all_feats.extend([[book['average_rating'], book['num_watched']]]*len(new_indexes))
        all_genres.extend([book_genres]*len(new_indexes))
        indexes.extend(new_indexes)
        
        if (i+1)%25000==0:
            print('{} examples - Total {} M'.format(i, (time.time() - start) // 60))
            # To be safe upload in chunks of 25,000
            idmap_df.loc[indexes, ['avg_rating', 'num_watched']] = all_feats
            idmap_df.loc[indexes, ['genres']] = pd.Series(all_genres, index=indexes)
            
            print(idmap_df.loc[indexes[:3]])
            all_feats, all_genres, indexes = [], [], []

    idmap_df.to_csv(BOOK_PATH + 'book_id_map-dedup-features-v1.csv')

def add_all_genre():
    books_count = Book.objects.count()
    book_genre = BookGenre(name='All', count=books_count)
    book_genre.save()

    movies_count = Movie.objects.count()
    movie_genre = MovieGenre(name='All', count=movies_count)
    movie_genre.save()


def quick_check():
    pass
    

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "MediaRecommendationServer.settings")

    django.setup()
    from MediaRecommendationServer import *
    from media.models import Movie, Book
    from userauth.models import User, MovieUser, BookUser
    from predictions.models import MoviePrediction
    from ratings.models import MovieRating, BookRating
    from genres.models import MovieGenre, BookGenre
    from series.models import MovieSeries, BookSeries


    if sys.argv[1] == 'import_movies':
        import_movies()

    elif sys.argv[1] == "import_movie_rating_stats":
        import_movie_rating_stats()

    elif sys.argv[1] == "import_movie_images":
        import_movie_images()

    elif sys.argv[1] == "import_books":
        import_books()

    elif sys.argv[1] == "remove_book_ratings_notin_django":
        remove_book_ratings_notin_django()

    elif sys.argv[1] == 'add_book_features_to_ratings':
        add_book_features_to_ratings()

    elif sys.argv[1] == "add_all_genre":
        add_all_genre()

    elif sys.argv[1] == 'quick_check':
        quick_check()

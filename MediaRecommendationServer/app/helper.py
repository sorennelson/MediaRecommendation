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

DATA_PATH = '../Data/ml-25m/'

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




def import_book_ratings():
    path = './book_ratings.csv'
    with open(path, 'r') as f:
        uid = 1
        csv_uid = 1
        user = BookUser(id=uid)
        user.save()

        for line in f:
            terms = line.strip().split(',')

            if terms[0] != csv_uid and terms[1] != str(3618):
                csv_uid = terms[0]
                uid += 1

                user = BookUser(id=uid)
                user.save()

                rating = BookRating(rating_user=user,
                                    book=Book.objects.get(id=int(terms[1])),
                                    rating=float(terms[2]))
                rating.save()

            elif terms[1] != str(3618):
                rating = BookRating(rating_user=user,
                                    book=Book.objects.get(id=int(terms[1])),
                                    rating=float(terms[2]))
                rating.save()


def add_book_genres():
    books = Book.objects.all()

    for book in books:
        for genre_name in book.genres:
            if BookGenre.objects.filter(name=genre_name).exists():
                psql_genre = BookGenre.objects.get(name=genre_name)
                psql_genre.books.add(book)
                psql_genre.books_count += 1
                psql_genre.save()
            else:
                psql_genre = BookGenre(name=genre_name,
                                       books_count=1)
                psql_genre.save()
                psql_genre.books.add(book)


def add_all_genre():
    books_count = Book.objects.count()
    book_genre = BookGenre(name='All', books_count=books_count)
    book_genre.save()

    movies_count = Movie.objects.count()
    movie_genre = MovieGenre(name='All', count=movies_count)
    movie_genre.save()


def remove_small_book_genres():
    for count in range(5, 10):
        genres = BookGenre.objects.filter(count=count)
        for genre in genres:
            genre.delete()


def set_num_watched():
    movies = Movie.objects.all()
    for movie in movies:
        num_watched = MovieRating.objects.filter(movie=movie).count()
        movie.num_watched = num_watched
        movie.save()

    books = Book.objects.all()
    for book in books:
        num_watched = BookRating.objects.filter(book=book).count()
        book.num_watched = num_watched
        book.save()


def add_book_work_id():
    path = './books.csv'
    with open(path, 'r') as f:
        for line in f:
            terms = line.strip().split(',')
            work_id = int(terms[3])
            goodreads_id = int(terms[1])
            books = Book.objects.filter(goodreads_id=goodreads_id).all()
            if books.count() < 1:
                print("DNE", goodreads_id)
            else:
                book = books[0]
                book.work_id = work_id
                book.save()


def set_book_series():
    conn = http.client.HTTPSConnection("www.goodreads.com")
    books = Book.objects.all()

    i = 1
    for book in books:
        if i > 1154:
            print(i, book.id)

            payload = "{}"
            url = "/series/work/" + str(book.work_id) + "?format=xml&key=UAHiKRW5GiTcCQXsFq9Ckg"
            conn.request("GET", url, payload)
            res = conn.getresponse()
            data = res.read()
            xml = data.decode("utf-8")
            response_dict = xmltodict.parse(xml)
            series_dict = response_dict['GoodreadsResponse']

            if 'series_works' in series_dict.keys():
                series_dict = series_dict['series_works']
                if series_dict:
                    # Multiple series
                    if type(series_dict['series_work']) == list:
                        series_dict = series_dict['series_work']
                        for s in series_dict:
                            add_book_to_series(s['series'], book)

                    else:
                        series_dict = series_dict['series_work']['series']
                        add_book_to_series(series_dict, book)

            else:
                print("ERROR IN RESPONSE", book.id, book.work_id)
        i += 1


def add_book_to_series(series_dict, book):
    series_id = int(series_dict['id'])
    series_title = series_dict['title']

    if BookSeries.objects.filter(goodreads_id=series_id).exists():
        series = BookSeries.objects.get(goodreads_id=series_id)
    else:
        series = BookSeries(goodreads_id=series_id, name=series_title)
        series.save()

    series.books.add(book)


def order_book_series():
    series = BookSeries.objects.all()
    for s in series:
        avg_sum = 0.0
        for book in s.books.all():
            avg_sum += book.average_rating
        s.avg_rating = avg_sum / s.books.count()
        s.save()


def set_book_series_most_viewed():
    series = BookSeries.objects.all()
    for s in series:
        highest = s.books.all()[0]
        for book in s.books.all():
            if highest.average_rating < book.average_rating:
                highest = book
        s.most_viewed = highest
        s.save()


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

    elif sys.argv[1] == "import_book_ratings":
        import_book_ratings()

    elif sys.argv[1] == "import_movie_rating_stats":
        import_movie_rating_stats()

    elif sys.argv[1] == "add_book_genres":
        add_book_genres()

    elif sys.argv[1] == "add_all_genre":
        add_all_genre()

    elif sys.argv[1] == "remove_small_book_genres":
        remove_small_book_genres()

    elif sys.argv[1] == "import_movie_images":
        import_movie_images()

    elif sys.argv[1] == 'set_num_watched':
        set_num_watched()

    elif sys.argv[1] == 'add_book_work_id':
        add_book_work_id()

    elif sys.argv[1] == 'set_book_series':
        set_book_series()

    elif sys.argv[1] == 'order_book_series':
        order_book_series()

    elif sys.argv[1] == 'set_book_series_most_viewed':
        set_book_series_most_viewed()

    elif sys.argv[1] == 'quick_check':
        quick_check()

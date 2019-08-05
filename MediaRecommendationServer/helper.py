import sys
import os
import django
from django.conf import settings

import re
import http.client
import time
import xmltodict
import json


def import_movie_ratings():
    """Imports the data at the given path to a csv file."""
    path = './movie_ratings.csv'
    with open(path, 'r') as f:
        uid = 1
        user = MovieUser(id=uid)
        user.save()

        for line in f:
            terms = line.strip().split(',')

            if terms[0] != uid and terms[1] != str(62437):
                uid = terms[0]
                user = MovieUser(id=uid)
                user.save()

                rating = MovieRating(rating_user=user,
                                     movie=Movie.objects.get(id=int(terms[1])),
                                     rating=float(terms[2]))
                rating.save()

            elif terms[1] != str(62437):
                rating = MovieRating(rating_user=user,
                                     movie=Movie.objects.get(id=int(terms[1])),
                                     rating=float(terms[2]))
                rating.save()


def set_movie_images():
    conn = http.client.HTTPSConnection("api.themoviedb.org")
    path = './links.csv'
    with open(path, 'r') as f:
        i = 1
        for line in f:
            terms = line.strip().split(',')

            if int(terms[0]) > 84847:
                print(terms[0])

                if i % 40 == 0:
                    time.sleep(11)
                payload = "{}"
                url = "/3/movie/" + terms[2] + "?language=en-US&api_key=60d78c7cfee3c407c714903efd4c3359"
                conn.request("GET", url, payload)

                res = conn.getresponse()
                data = res.read()
                json = data.decode("utf-8")

                poster_str = re.search(r'"poster_path":\s?"\/.{25}.?.?.?\.jpg"', json)
                try:
                    poster_str = poster_str[0]
                    poster_url = re.search(r'\/.*', poster_str)[0]
                    poster_url = poster_url[:-1]

                    avg_str = re.search(r'"vote_average":\d\d?\.\d\d?', json)[0]
                    avg = float(re.search(r'\d\d?\.\d', avg_str)[0])

                    movie = Movie.objects.get(pk=terms[0])
                    movie.image_url = 'https://image.tmdb.org/t/p/w342' + poster_url
                    movie.average_rating = avg
                    movie.save()
                except TypeError:
                    print(i, json)
                i += 1


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


def add_movie_genres():
    movies = Movie.objects.all()

    for movie in movies:
        for genre_name in movie.genres:
            if MovieGenre.objects.filter(name=genre_name).exists():
                psql_genre = MovieGenre.objects.get(name=genre_name)
                psql_genre.movies.add(movie)
                psql_genre.movies_count += 1
                psql_genre.save()
            else:
                psql_genre = MovieGenre(name=genre_name,
                                        movies_count=1)
                psql_genre.save()
                psql_genre.movies.add(movie)


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
    movie_genre = MovieGenre(name='All', movies_count=movies_count)
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


def set_movie_series():
    conn = http.client.HTTPSConnection("api.themoviedb.org")
    path = './links.csv'
    with open(path, 'r') as f:
        i = 1
        for line in f:
            terms = line.strip().split(',')

            if int(terms[0]) > 85774:
                print(terms[0])

                if i % 40 == 0:
                    time.sleep(11)
                payload = "{}"
                url = "/3/movie/" + terms[2] + "?language=en-US&api_key=60d78c7cfee3c407c714903efd4c3359"
                conn.request("GET", url, payload)

                res = conn.getresponse()
                data = res.read()
                json_dict = json.loads(data.decode("utf-8"))

                if 'belongs_to_collection' in json_dict.keys() and json_dict['belongs_to_collection']:
                    movie = Movie.objects.get(pk=int(terms[0]))
                    movie.tmdb_id = int(terms[2])
                    movie.save()

                    add_movie_to_series(json_dict['belongs_to_collection'], movie)

                i += 1


def add_movie_to_series(series_dict, movie):
    series_id = int(series_dict['id'])
    series_title = series_dict['name']

    if MovieSeries.objects.filter(tmdb_id=series_id).exists():
        series = MovieSeries.objects.get(tmdb_id=series_id)
    else:
        series = MovieSeries(tmdb_id=series_id, name=series_title, avg_rating=0.0)
        series.save()

    series.movies.add(movie)


def order_movie_series():
    series = MovieSeries.objects.all()
    for s in series:
        avg_sum = 0.0
        highest = s.movies.all()[0]
        for movie in s.movies.all():
            avg_sum += movie.average_rating
            if highest.average_rating < movie.average_rating:
                highest = movie
        s.avg_rating = avg_sum / s.movies.count()
        s.most_viewed = highest
        s.save()


def quick_check():
    book = Book.objects.get(pk=8768)
    print(book.work_id)


if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "MediaRecommendationServer.settings")

    django.setup()
    from MediaRecommendationServer import *
    import mlmodels.helper as ml
    from media.models import Movie, Book
    from userauth.models import MovieUser, BookUser
    from ratings.models import MovieRating, BookRating
    from genres.models import MovieGenre, BookGenre
    from series.models import MovieSeries, BookSeries

    if sys.argv[1] == "import_book_ratings":
        import_book_ratings()

    elif sys.argv[1] == "import_movie_ratings":
        import_movie_ratings()

    elif sys.argv[1] == "run_book_ml":
        ml.run_collaborative_filtering('books', int(sys.argv[2]))

    elif sys.argv[1] == "run_movie_ml":
        ml.run_collaborative_filtering('movies', int(sys.argv[2]))

    elif sys.argv[1] == "add_movie_genres":
        add_movie_genres()

    elif sys.argv[1] == "add_book_genres":
        add_book_genres()

    elif sys.argv[1] == "add_all_genre":
        add_all_genre()

    elif sys.argv[1] == "remove_small_book_genres":
        remove_small_book_genres()

    elif sys.argv[1] == "set_movie_images":
        set_movie_images()

    elif sys.argv[1] == 'add_movie_rating':
        ml.add_rating('movie', 1, 467, 3.0)

    elif sys.argv[1] == 'set_num_watched':
        set_num_watched()

    elif sys.argv[1] == 'add_book_work_id':
        add_book_work_id()

    elif sys.argv[1] == 'set_book_series':
        set_book_series()

    elif sys.argv[1] == 'set_movie_series':
        set_movie_series()

    elif sys.argv[1] == 'order_book_series':
        order_book_series()

    elif sys.argv[1] == 'order_movie_series':
        order_movie_series()

    elif sys.argv[1] == 'set_book_series_most_viewed':
        set_book_series_most_viewed()

    elif sys.argv[1] == 'quick_check':
        quick_check()

import sys
import os
import django
from django.conf import settings

import re
import http.client
import time



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


def set_movie_images():
    conn = http.client.HTTPSConnection("api.themoviedb.org")
    path = './links.csv'
    with open(path, 'r') as f:
        i = 1
        for line in f:
            terms = line.strip().split(',')

            if int(terms[0]) > 66934:
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


if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "MediaRecommendationServer.settings")

    django.setup()
    from MediaRecommendationServer import *
    import mlmodels.helper as ml
    from media.models import Movie, Book
    from userauth.models import MovieUser, BookUser
    from ratings.models import MovieRating, BookRating
    from genres.models import MovieGenre, BookGenre

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

import sys
import os
import django
from django.conf import settings


def import_movie_ratings():
    """Imports the data at the given path to a csv file."""
    path = './movie_ratings.csv'
    with open(path, 'r') as f:
        uid = 1
        movie_ids = []
        ratings = []

        for line in f:
            terms = line.strip().split(',')

            if terms[0] != uid and terms[1] != str(62437):
                user = models.MovieRatingUser(movie_ratings=ratings)
                user.save()
                user.movie_rating_ids.set(movie_ids)

                uid = terms[0]
                movie_ids = [int(terms[1])]
                ratings = [float(terms[2])]
            elif terms[1] != str(62437):
                movie_ids.append(int(terms[1]))
                ratings.append(float(terms[2]))


def import_book_ratings():
    path = './book_ratings.csv'
    with open(path, 'r') as f:
        uid = 1
        book_ids = []
        ratings = []

        for line in f:
            terms = line.strip().split(',')

            if terms[0] != uid and terms[1] != str(3618):
                user = models.BookRatingUser(book_ratings=ratings)
                user.save()
                user.book_rating_ids.set(book_ids)

                uid = terms[0]
                book_ids = [int(terms[1])]
                ratings = [float(terms[2])]

            elif terms[1] != str(3618):
                book_ids.append(int(terms[1]))
                ratings.append(float(terms[2]))


# def update_movie_ids():
#     movies = Movie.objects.all()
#     num_media = movies.count()
#
#     mapping = {}
#     for i in range(num_media):
#         mapping[movies[i].id] = i
#
#     users = MovieRatingUser.objects.order_by('id')

    # for user in users:


if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "MediaRecommendationServer.settings")

    django.setup()
    from MediaRecommendationServer import *
    import ratings.models as models
    import mlmodels.helper as ml
    from media.models import Movie
    from ratings.models import MovieRatingUser

    if sys.argv[1] == "import_books":
        import_book_ratings()

    elif sys.argv[1] == "import_movies":
        import_movie_ratings()

    elif sys.argv[1] == "run_book_ml":
        ml.run_collaborative_filtering('books')

    elif sys.argv[1] == "run_movie_ml":
        ml.run_collaborative_filtering('movies')

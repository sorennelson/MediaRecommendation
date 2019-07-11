import numpy as np
from sklearn.metrics import mean_squared_error

from media.models import Book, Movie
from ratings.models import BookRatingUser, MovieRatingUser


def run_collaborative_filtering(media_type):
    if media_type == "books":
        num_media, num_users, ratings, ratings_mean, rated = __setup_book_matrices()
        reg_params = [0.05, 0.1, 2.5]
        learning_rates = [0.0001, 0.0005]
    else:
        # reg_params = [0.01, 0.05, 0.1]
        # learning_rates = [0.00005, 0.0001]
        reg_params = [2.5]
        learning_rates = [0.0001]
        mapping, num_media, num_users, ratings, ratings_mean, rated = __setup_movie_matrices()

    best = [0, 0, 0, 1.0]
    param_count = [10, 12, 20]
    # param_count = [8]
    rated_indices = __get_rated_indices(rated)

    for num_params in param_count:
        i = 0
        for reg_param in reg_params:
            for learning_rate in learning_rates:
                print(num_params, ', R:', reg_param, ', LR:', learning_rate)

                user_params, item_params = __set_user_item_params(num_media, num_params, num_users)
                train_ratings, train_rated, val_ratings, val_indices = __separate_validation_set(i, ratings, rated, rated_indices)

                losses, item_params, user_params = \
                    __run_gradient_descent(500, reg_param, learning_rate, user_params, item_params, train_ratings, train_rated)
                # print("LOSS:", losses)

                rmse = __compute_rmse(user_params, item_params, ratings, ratings_mean)
                print("RMSE:", rmse)

                val_rmse = __compute_val_rmse(user_params, item_params, val_ratings, val_indices, ratings_mean)
                print("VAL RMSE:", val_rmse)

                if val_rmse < best[3]:
                    best = [num_params, reg_param, learning_rate, val_rmse]

                i += 1
    print("BEST MODEL:", best[0], best[1], best[2], best[3])

    user_params, item_params = __set_user_item_params(num_media, best[0], num_users)
    losses, item_params, user_params = \
        __run_gradient_descent(300, best[1], best[2], user_params, item_params, ratings, rated)

    rmse = __compute_rmse(user_params, item_params, ratings, ratings_mean)
    print("RMSE:", rmse)

    __create_movie_predictions(mapping, user_params, item_params, rated, ratings_mean)

#     Train best model on full data
#     After CV, create predictions


def __setup_book_matrices():
    num_media = Book.objects.count() + 9
    users = BookRatingUser.objects.order_by('id')

    ratings = np.zeros((num_media, users.count()))
    rated = np.zeros((num_media, users.count()))

    for u in range(users.count()):
        ids = users[u].book_rating_ids.all()

        for r in range(ids.count()):
            book_id = ids[r].id
            rating = users[u].book_ratings[r]

            ratings[book_id, u] = rating
            rated[book_id, u] = 1

    ratings_mean = np.mean(ratings, axis=1)
    ratings = ratings - ratings_mean.reshape(-1, 1)     # De-mean: https://beckernick.github.io/matrix-factorization-recommender/

    return num_media, users.count(), ratings, ratings_mean, rated


def __setup_movie_matrices():
    movies = Movie.objects.all()
    num_media = movies.count()

    mapping = {}
    for i in range(num_media):
        mapping[movies[i].id] = i

    users = MovieRatingUser.objects.order_by('id')
    ratings = np.zeros((num_media, users.count()))
    rated = np.zeros((num_media, users.count()))

    for u in range(users.count()):
        ids = users[u].movie_rating_ids.all()

        for r in range(ids.count()):
            movie_id = ids[r].id
            rating = users[u].movie_ratings[r]

            map_id = mapping[movie_id]

            ratings[map_id, u] = rating
            rated[map_id, u] = 1

    ratings_mean = np.mean(ratings, axis=1)
    ratings = ratings - ratings_mean.reshape(-1, 1)

    return mapping, num_media, users.count(), ratings, ratings_mean, rated


def __set_user_item_params(num_media, num_features, num_users):
    item_params = np.random.rand(num_media, num_features)
    user_params = np.random.rand(num_users, num_features)
    return user_params, item_params


def __get_rated_indices(rated):
    rated_indices = np.nonzero(rated)
    shuffled_indices = list(zip(rated_indices[0], rated_indices[1]))
    np.random.shuffle(shuffled_indices)
    return shuffled_indices


def __separate_validation_set(i, ratings, rated, rated_indices):
    start = int(0.1 * len(rated_indices) * i)
    end = int(0.1 * len(rated_indices) * (i+1))

    val_indices = []
    val_ratings = []

    train_ratings = ratings.copy()
    train_rated = rated.copy()

    for i in range(start, end):
        x, y = rated_indices[i]

        val_indices.append(rated_indices[i])
        val_ratings.append(ratings[x, y])

        train_ratings[x, y] = 0
        train_rated[x, y] = 0

    val_indices = np.array(val_indices)
    val_ratings = np.array(val_ratings)

    return train_ratings, train_rated, val_ratings, val_indices


# MARK: Gradient Descent
def __run_gradient_descent(num_iters, reg_param, learning_rate, user_params, item_params, ratings, rated):
    losses = []

    for i in range(num_iters):
        error = __compute_error(user_params, item_params, ratings, rated)
        item_gradient = __compute_item_gradient(reg_param, error, user_params, item_params)
        user_gradient = __compute_user_gradient(reg_param, error, user_params, item_params)

        loss = __compute_loss(reg_param, error, user_params, item_params)
        losses.append(loss)

        item_params -= learning_rate * item_gradient
        user_params -= learning_rate * user_gradient

    return losses, item_params, user_params


def __compute_error(user_params, item_params, ratings, rated):
    error = np.dot(item_params, user_params.T) - ratings
    return rated * error  # only for rated media


def __compute_item_gradient(reg_param, error, user_params, item_params):
    gradient = np.dot(error, user_params)
    regularization = reg_param * item_params
    return gradient + regularization


def __compute_user_gradient(reg_param, error, user_params, item_params):
    gradient = np.dot(error.T, item_params)
    regularization = reg_param * user_params
    return gradient + regularization


def __compute_loss(reg_param, error, user_params, item_params):
    loss = np.sum(np.square(error)) / 2
    item_regularization = (reg_param / 2) * np.sum(np.square(item_params))
    user_regularization = (reg_param / 2) * np.sum(np.square(user_params))
    return loss + item_regularization + user_regularization


# MARK: TESTING
def __compute_rmse(user_params, item_params, ratings, ratings_mean):
    predictions = np.dot(item_params, user_params.T)
    predictions += ratings_mean.reshape(-1, 1)
    return np.sqrt(mean_squared_error(ratings, predictions)) / 5


def __compute_val_rmse(user_params, item_params, val_ratings, val_indices, ratings_mean):
    all_predictions = np.dot(item_params, user_params.T)
    all_predictions += ratings_mean.reshape(-1, 1)

    predictions = []

    for i in range(len(val_indices)):
        x, y = val_indices[i]
        predictions.append(all_predictions[x, y])

    predictions = np.array(predictions)

    return np.sqrt(mean_squared_error(val_ratings, predictions)) / 5


# MARK: PREDICTIONS
def __create_movie_predictions(mapping, user_params, item_params, rated, ratings_mean):
    predictions = np.dot(item_params, user_params.T)
    predictions += ratings_mean.reshape(-1, 1)

    non_rated = (rated - 1) * (- 1)
    print(rated[0, 0], non_rated[0, 0])
    predictions *= non_rated

    users = MovieRatingUser.objects.order_by('id')
    for user in users:
        movie_id_predictions = []

        for key, value in mapping.items():
            prediction = predictions[value, user.id-1]
            if prediction != 0:
                movie_id_predictions.append((key, prediction))

        sorted_predictions = sorted(movie_id_predictions, key=lambda tup: tup[1], reverse=True)
        print(sorted_predictions[0])
        user.predictions.set([i[0] for i in sorted_predictions])
        user.save()

    # remove predictions of movies they've already seen?
    # add to serializers


def get_similar_items(id):
    #   find smallest ||item_params(id) - item_params(j)||
    #   will need to store user/item params then
    print('similar')

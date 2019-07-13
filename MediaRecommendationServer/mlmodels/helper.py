import numpy as np
from sklearn.metrics import mean_squared_error

from . import cfmodel

from media.models import Book, Movie
from userauth.models import BookUser, MovieUser
from predictions.models import BookPrediction, MoviePrediction


def run_collaborative_filtering(media_type):
    model = cfmodel.CollaborativeFilteringModel(media_type)
    best = [0, 0, 0, 1.0]
    param_count = [10, 12, 20]
    # param_count = [8]

    if media_type == "books":
        reg_params = [0.05, 0.1, 1, 2]
        learning_rates = [0.00005, 0.0001]
    else:
        # reg_params = [0.01, 0.05, 0.1]
        # learning_rates = [0.00005, 0.0001]
        reg_params = [2.5]
        learning_rates = [0.0001]

    for features_num in param_count:
        i = 0
        for reg_param in reg_params:
            for learning_rate in learning_rates:
                best = __run_hyperparameters(model, features_num, reg_param, learning_rate, i, best)
                i += 1
    print("BEST MODEL:", best[0], best[1], best[2], best[3])

    model.set_user_item_params(best[0])
    losses = __run_gradient_descent(500, model, best[1], best[2])

    rmse = __compute_rmse(model)
    print("RMSE:", rmse)

    if media_type == 'books':
        __create_book_predictions(model)
    else:
        __create_movie_predictions(model)


def __run_hyperparameters(model, features_num, reg_param, learning_rate, iteration, best):
    print(features_num, ', R:', reg_param, ', LR:', learning_rate)

    model.set_user_item_params( features_num)
    model.separate_validation_set(iteration)

    losses = __run_gradient_descent(500, model, reg_param, learning_rate)
    # print("LOSS:", losses)

    rmse = __compute_rmse(model)
    print("RMSE:", rmse)

    val_rmse = __compute_val_rmse(model)
    print("VAL RMSE:", val_rmse)

    return [model.features_num, reg_param, learning_rate, val_rmse] if val_rmse < best[3] else best


# MARK: Gradient Descent
def __run_gradient_descent(num_iters, model, reg_param, learning_rate):
    losses = []

    for i in range(num_iters):
        error = __compute_error(model)
        item_gradient = __compute_item_gradient(error, model, reg_param)
        user_gradient = __compute_user_gradient(error, model, reg_param)

        loss = __compute_loss(error, model, reg_param)
        losses.append(loss)

        model.item_params -= learning_rate * item_gradient
        model.user_params -= learning_rate * user_gradient

    return losses


def __compute_error(model):
    error = np.dot(model.item_params, model.user_params.T) - model.ratings
    return model.rated * error  # only for rated media


def __compute_item_gradient(error, model, reg_param):
    gradient = np.dot(error, model.user_params)
    regularization = reg_param * model.item_params
    return gradient + regularization


def __compute_user_gradient(error, model, reg_param):
    gradient = np.dot(error.T, model.item_params)
    regularization = reg_param * model.user_params
    return gradient + regularization


def __compute_loss(error, model, reg_param):
    loss = np.sum(np.square(error)) / 2
    item_regularization = (reg_param / 2) * np.sum(np.square(model.item_params))
    user_regularization = (reg_param / 2) * np.sum(np.square(model.user_params))
    return loss + item_regularization + user_regularization

# TODO: Add training testing

# MARK: TESTING
def __compute_rmse(model):
    predictions = np.dot(model.item_params, model.user_params.T)
    predictions += model.ratings_mean.reshape(-1, 1)
    return np.sqrt(mean_squared_error(model.ratings, predictions)) / 5


def __compute_val_rmse(model):
    all_predictions = np.dot(model.item_params, model.user_params.T)
    all_predictions += model.ratings_mean.reshape(-1, 1)

    predictions = []

    for i in range(len(model.val_indices)):
        x, y = model.val_indices[i]
        predictions.append(all_predictions[x, y])

    predictions = np.array(predictions)

    return np.sqrt(mean_squared_error(model.val_ratings, predictions)) / 5


# MARK: PREDICTIONS
def __create_book_predictions(model):
    predictions = np.dot(model.item_params, model.user_params.T)
    predictions += model.ratings_mean.reshape(-1, 1)

    non_rated = (model.rated - 1) * (- 1)
    predictions *= non_rated  # zero out rated movies

    users = BookUser.objects.order_by('id')
    for user in users:

        for psql_bid, np_bid in model.mapping.items():
            # user_predictions = predictions[:, user.id-1]
            # user_predictions
            # TODO: Top n predictions only
            prediction_val = predictions[np_bid, user.id - 1]

            if prediction_val != 0:
                prediction_obj = BookPrediction(prediction_user=user,
                                                book=Book.objects.get(id=psql_bid),
                                                prediction=prediction_val)
                prediction_obj.save()
        print(user.id)


def __create_movie_predictions(model):
    predictions = np.dot(model.item_params, model.user_params.T)
    predictions += model.ratings_mean.reshape(-1, 1)

    non_rated = (model.rated - 1) * (- 1)
    predictions *= non_rated    # zero out rated movies

    users = MovieUser.objects.order_by('id')
    for user in users:

        for psql_mid, np_mid in model.mapping.items():
            # user_predictions = predictions[:, user.id-1]
            # user_predictions
            # TODO: Top n predictions only
            prediction_val = predictions[np_mid, user.id-1]

            if prediction_val != 0:
                prediction_obj = MoviePrediction(prediction_user=user,
                                                 movie=Movie.objects.get(id=psql_mid),
                                                 prediction=prediction_val)
                prediction_obj.save()
        print(user.id)


def get_similar_items(id):
    #   find smallest ||item_params(id) - item_params(j)||
    #   will need to store user/item params then
    print('similar')

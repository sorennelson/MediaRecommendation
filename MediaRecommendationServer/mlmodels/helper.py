import numpy as np
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt

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
        learning_rates = [0.0001]
    else:
        # reg_params = [0.01, 0.05, 0.1]
        # learning_rates = [0.00005, 0.0001]
        reg_params = [2.5]
        learning_rates = [0.0001]

    for features_num in param_count:
        i = 0
        for reg_param in reg_params:
            for learning_rate in learning_rates:
                best = _run_hyperparameters(model, 500, features_num, learning_rate, i, best, reg_param)
                i += 1
    print("BEST MODEL:", best[0], best[1], best[2], best[3])

    model.set_user_item_params(best[0])
    losses, _ = _run_gradient_descent(500, model, best[2], best[1])

    rmse = _compute_rmse(model)
    print("RMSE:", rmse)

    if media_type == 'books':
        _create_book_predictions(model)
    else:
        _create_movie_predictions(model)


def overfit_collaborative_filtering(media_type):
    model = cfmodel.CollaborativeFilteringModel(media_type)
    best = [0, 0, 0, 1.0]
    param_count = [10, 20, 30, 50]

    if media_type == "books":
        learning_rates = [0.0001]
    else:
        learning_rates = [0.001]

    i = 0
    for features_num in param_count:
        for learning_rate in learning_rates:
            best = _run_hyperparameters(model, 300, features_num, learning_rate, i, best)
            i += 1


def _run_hyperparameters(model, num_epochs, features_num, learning_rate, iteration, best, reg_param=0):
    print(features_num, ', R:', reg_param, ', LR:', learning_rate)

    model.set_user_item_params(features_num)
    model.separate_validation_set(iteration)

    losses, val_losses = _run_gradient_descent(num_epochs, model, learning_rate, reg_param)
    _create_loss_graph(losses, val_losses)

    rmse = _compute_rmse(model)
    print("RMSE:", rmse)

    val_rmse = _compute_val_rmse(model)
    print("VAL RMSE:", val_rmse)

    return [model.features_num, reg_param, learning_rate, val_rmse] if val_rmse < best[3] else best


# MARK: Gradient Descent
def _run_gradient_descent(num_iters, model, learning_rate, reg_param):
    train_losses = []
    val_losses = []

    for i in range(num_iters):
        error = _compute_error(model)
        item_gradient = _compute_item_gradient(error, model, reg_param)
        user_gradient = _compute_user_gradient(error, model, reg_param)

        loss = _compute_loss(error, model, reg_param)
        train_losses.append(loss)

        val_loss = _compute_val_loss(model)
        val_losses.append(val_loss)

        model.item_params -= learning_rate * item_gradient
        model.user_params -= learning_rate * user_gradient

    return train_losses, val_losses


def _compute_error(model):
    error = np.dot(model.item_params, model.user_params.T) - model.train_ratings
    return model.train_rated * error  # only for rated media


def _compute_item_gradient(error, model, reg_param):
    gradient = np.dot(error, model.user_params)
    regularization = reg_param * model.item_params if reg_param != 0 else 0
    return gradient + regularization


def _compute_user_gradient(error, model, reg_param):
    gradient = np.dot(error.T, model.item_params)
    regularization = reg_param * model.user_params if reg_param != 0 else 0
    return gradient + regularization


def _compute_loss(error, model, reg_param):
    loss = np.sum(np.square(error)) / 2
    item_regularization = (reg_param / 2) * np.sum(np.square(model.item_params)) if reg_param != 0 else 0
    user_regularization = (reg_param / 2) * np.sum(np.square(model.user_params)) if reg_param != 0 else 0

    return loss + item_regularization + user_regularization


def _compute_val_loss(model):
    all_predictions = np.dot(model.item_params, model.user_params.T)
    predictions = []

    for i in range(len(model.val_indices)):
        x, y = model.val_indices[i]
        predictions.append(all_predictions[x, y])

    predictions = np.array(predictions)
    error = predictions - model.val_ratings
    loss = np.sum(np.square(error)) / 2
    return loss


# MARK: TESTING
def _create_loss_graph(train_losses, val_losses):
    train_losses = [train_losses[i] for i in range(len(train_losses)) if i % 10 == 0]
    val_losses = [val_losses[i] for i in range(len(val_losses)) if i % 10 == 0]

    epochs = range(1, len(train_losses) + 1)
    plt.plot(epochs, train_losses, 'bo', label='Train Loss')
    plt.plot(epochs, val_losses, 'b', label='Validation Loss')
    plt.title('Training and Validation Loss')
    plt.legend()
    plt.show()


# TODO: Add training testing
def _compute_rmse(model):
    predictions = np.dot(model.item_params, model.user_params.T)
    predictions += model.ratings_mean.reshape(-1, 1)

    ratings = model.ratings.copy()

    for i in range(len(model.val_indices)):
        x, y = model.val_indices[i]
        predictions[x, y] = 0
        ratings[x, y] = 0

    return np.sqrt(mean_squared_error(ratings, predictions)) / 5


def _compute_val_rmse(model):
    all_predictions = np.dot(model.item_params, model.user_params.T)
    all_predictions += model.ratings_mean.reshape(-1, 1)

    predictions = []

    for i in range(len(model.val_indices)):
        x, y = model.val_indices[i]
        predictions.append(all_predictions[x, y])

    predictions = np.array(predictions)

    return np.sqrt(mean_squared_error(model.val_ratings, predictions)) / 5


# MARK: PREDICTIONS
def _create_book_predictions(model):
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


def _create_movie_predictions(model):
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

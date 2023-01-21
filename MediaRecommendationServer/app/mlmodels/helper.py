import numpy as np
from sklearn.metrics import mean_squared_error

from . import cfmodel, models

from media.models import Book, Movie
from userauth.models import BookUser, MovieUser
from predictions.models import BookPrediction, MoviePrediction


def add_user(media_type, uid):
    if media_type == 'books':
        mlmodel = models.MLModel.objects.get(pk=1)
    else:
        mlmodel = models.MLModel.objects.get(pk=1)
    model = mlmodel.cfmodel

    model.add_user()
    model.reset_ratings()

    if media_type == 'books':
        _, _ = _run_gradient_descent(5, model, 0.0002, 120, False)

    else:
        _, _ = _run_gradient_descent(5, model, 0.001, 100, False)
        _create_movie_predictions(model, uid)

    mlmodel.cfmodel = model
    mlmodel.save()


def add_rating(media_type, media_id, user_id, rating):
    if media_type == 'books':
        mlmodel = models.MLModel.objects.get(pk=1)
    else:
        mlmodel = models.MLModel.objects.get(pk=1)
    model = mlmodel.cfmodel

    model.add_rating(media_id, user_id, rating)
    model.reset_ratings()

    if media_type == 'books':
        _create_book_predictions(model)
    else:
        _create_movie_predictions(model)

    mlmodel.cfmodel = model
    mlmodel.save()


def run_collaborative_filtering(media_type, predict):
    model = cfmodel.CollaborativeFilteringModel(media_type)
    best = [0, 0, 0, 1.0]

    if media_type == "books":
        iterations = 300
        param_count = [6]
        reg_params = [120]
        learning_rates = [0.0002]
    else:
        iterations = 300
        param_count = [8]
        reg_params = [100]
        learning_rates = [0.001]

    for features_num in param_count:
        i = 0
        for reg_param in reg_params:
            for learning_rate in learning_rates:
                best = _run_hyperparameters(model, iterations, features_num, learning_rate, i, best, True, reg_param)
                i += 1
    print("BEST MODEL:", best[0], best[1], best[2], best[3])

    model.set_user_item_params(best[0])
    model.reset_ratings()

    _, _ = _run_gradient_descent(iterations, model, best[2], best[1], False)
    rmse = _compute_rmse(model)
    print("RMSE:", rmse)

    if media_type == 'books' and predict:
        _create_book_predictions(model)
    elif predict:
        print('PREDICT')
        _create_movie_predictions(model)

    mlmodel = models.MLModel()
    mlmodel.cfmodel = model
    mlmodel.save()
    print('SAVED!!')


def _run_hyperparameters(model, num_epochs, features_num, learning_rate, iteration, best, val, reg_param=0):
    print(features_num, ', R:', reg_param, ', LR:', learning_rate, ', Epochs:', num_epochs)

    model.set_user_item_params(features_num)
    model.separate_validation_set(iteration)

    _, _ = _run_gradient_descent(num_epochs, model, learning_rate, reg_param, val)

    rmse = _compute_rmse(model)
    print("RMSE:", rmse)

    val_rmse = _compute_val_rmse(model)
    print("VAL RMSE:", val_rmse)

    return [model.features_num, reg_param, learning_rate, val_rmse] if val_rmse < best[3] else best


# MARK: Gradient Descent
def _run_gradient_descent(num_iters, model, learning_rate, reg_param, val):
    train_losses = []
    val_losses = []

    for i in range(num_iters):
        error = _compute_error(model)
        item_gradient = _compute_item_gradient(error, model, reg_param)
        user_gradient = _compute_user_gradient(error, model, reg_param)

        loss = _compute_loss(error, model, reg_param)
        train_losses.append(loss)

        if val:
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
def _compute_rmse(model):
    predictions = np.dot(model.item_params, model.user_params.T) * 5
    predictions += model.ratings_mean.reshape(-1, 1)
    predictions *= model.train_rated

    return np.sqrt(mean_squared_error(model.train_ratings, predictions)) / 5


def _compute_val_rmse(model):
    all_predictions = np.dot(model.item_params, model.user_params.T) * 5
    all_predictions += model.ratings_mean.reshape(-1, 1)

    predictions = []

    for i in range(len(model.val_indices)):
        x, y = model.val_indices[i]
        predictions.append(all_predictions[x, y])

    predictions = np.array(predictions)

    return np.sqrt(mean_squared_error(model.val_ratings, predictions)) / 5


# MARK: PREDICTIONS
def _create_book_predictions(model, uid=13124):
    predictions = np.dot(model.item_params, model.user_params.T)
    predictions += model.ratings_mean.reshape(-1, 1)

    non_rated = (model.rated - 1) * (- 1)
    predictions *= non_rated  # zero out rated books

    users = BookUser.objects.order_by('id')
    for user in [user for user in users if user.id > uid]:

        for psql_bid, np_bid in model.mapping.items():
            curr_prediction = BookPrediction.objects.filter(prediction_user=user.id,
                                                            book=Book.objects.get(id=psql_bid))
            if curr_prediction.exists():
                curr_prediction.delete()

            prediction_val = predictions[np_bid, user.id-1]
            if prediction_val != 0:
                prediction_obj = BookPrediction(prediction_user=user,
                                                book=Book.objects.get(id=psql_bid),
                                                prediction=prediction_val)
                prediction_obj.save()
        print(user.id)


def _create_movie_predictions(model, uid=467):
    predictions = np.dot(model.item_params, model.user_params.T)
    predictions += model.ratings_mean.reshape(-1, 1)

    non_rated = (model.rated - 1) * (- 1)
    predictions *= non_rated  # zero out rated movies

    users = MovieUser.objects.order_by('id')
    for user in [user for user in users if user.id >= uid]:

        for psql_mid, np_mid in model.mapping.items():
            curr_prediction = MoviePrediction.objects.filter(prediction_user=user.id,
                                                             movie=Movie.objects.get(id=psql_mid))

            if curr_prediction.exists():
                curr_prediction.delete()

            prediction_val = predictions[np_mid, user.id - 1]

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

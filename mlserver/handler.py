from ts.torch_handler.base_handler import BaseHandler
import torch
import os
import pandas as pd
import nvtabular as nvt
from nvtabular.loader.torch import TorchAsyncItr, DLDataLoader


class Handler(BaseHandler):

    def __init__(self):
        super().__init__()
        self.workflow = nvt.Workflow.load('movie_workflow')

    
    def preprocess(self, data):
        """
        Preprocess function to convert the request input to a tensor(Torchserve supported format).
        The user needs to override to customize the pre-processing
        Args:
            data (list): List of the data from the request input. Must be of the form:
              {"userId": int, "movieId":[int], "genres": [[str]] "numRatings": [int], "avgRating": [float]}.
        Returns:
            tensor: Returns the tensor data of the input
        """
        body = data[0]['body']
        batch_size = len(body['movieId'])
        # Making predictions for the same user across each movie_id so expand
        uids = [body['userId']]*batch_size
        # Add throw away ratings
        ratings = [0.]*batch_size
        df = pd.DataFrame({'userId': uids, 
                           'movieId': body['movieId'], 
                           'rating': ratings})
        # 2 Dataframes to work with Join from Training Workflow
        df_movie = pd.DataFrame({'movieId': body['movieId'],
                                'split_genres': body['genres'],
                                'num_ratings': body['numRatings'],
                                'avg_rating': body['avgRating']})

        # TODO: Probably a faster way of transforming the ds without having to wrap in DL
        ds = TorchAsyncItr(
            self.workflow.transform(nvt.Dataset(df)),
            batch_size=batch_size,
            cats=['userId', 'movieId', 'split_genres'],
            conts=["rating", 'avg_rating', 'num_ratings'], 
        )
        dl = DLDataLoader(ds, batch_size=None, pin_memory=False, num_workers=0)
        data = next(iter(dl))

        user = data[0]['userId'].to(self.device)
        media = data[0]['movieId'].to(self.device)
        genres = [data[0]['split_genres'][0].to(self.device),
                  data[0]['split_genres'][1].to(self.device)]
        extra_feats = [data[0]['avg_rating'].to(self.device), 
                       data[0]['num_ratings'].to(self.device)]

        # print((user, media, genres, extra_feats))
        return (user, media, genres, extra_feats)

    def inference(self, data, *args, **kwargs):
        """
        The Inference Function is used to make a prediction call on the given input request.
        The user needs to override the inference function to customize it.
        Args:
            data (Torch Tensor): A Torch Tensor is passed to make the Inference Request.
            The shape should match the model input shape.
        Returns:
            Torch Tensor : The Predicted Torch Tensor is returned in this function.
        """
        # print(self.model.code)
        with torch.no_grad():
            results = self.model(*data, *args, **kwargs)
        # Batch size needs to stay the same for input/output so reshape to (1,movieIds)
        results = results.view(1,results.shape[0])
        return results

from media_handler import MediaHandler
import torch
import os
import pandas as pd
import nvtabular as nvt
from nvtabular.loader.torch import TorchAsyncItr, DLDataLoader


class MovieHandler(MediaHandler):

    def __init__(self):
        super().__init__('movie_workflow')
    
    def preprocess(self, data):
        """
        Preprocess function to convert the request input to a tensor(Torchserve supported format).
        Args:
            data (list): List of the data from the request input. Must be of the form:
              {"userId": int, "movieId":[int], "genres": [[str]] "numRatings": [int], "avgRating": [float]}.
        Returns:
            tensor: Returns the tensor data of the input
        """
        body = data[0]['body']
        batch_size = len(body['movieId'])
        # Making predictions for the same user across each movie_id so expand
        # Throw away user. Will add in the actual user later as the workflow alters the userId
        uids = [0]*batch_size
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

        user = (data[0]['userId'] + body['userId']).to(self.device)
        media = data[0]['movieId'].to(self.device)
        genres = [data[0]['split_genres'][0].to(self.device),
                  data[0]['split_genres'][1].to(self.device)]
        extra_feats = [data[0]['avg_rating'].to(self.device), 
                       data[0]['num_ratings'].to(self.device)]

        return (user, media, genres, extra_feats)
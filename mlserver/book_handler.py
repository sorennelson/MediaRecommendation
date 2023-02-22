from media_handler import MediaHandler
import torch
import os
import pandas as pd
import nvtabular as nvt
from nvtabular.loader.torch import TorchAsyncItr, DLDataLoader


class BookHandler(MediaHandler):

    def __init__(self):
        super().__init__('book_workflow')
        df_idmap = pd.read_csv('book_workflow/book_id_map-dedup-v1.csv')
        df_idmap = df_idmap.drop(columns=['Unnamed: 0'])
        df_idmap = df_idmap.rename(columns={'book_id': 'goodreads_id'})
        df_idmap = df_idmap.rename(columns={'book_id_csv': 'book_id'})
        self.df_idmap = df_idmap
    
    def preprocess(self, data):
        """
        Preprocess function to convert the request input to a tensor(Torchserve supported format).
        Args:
            data (list): List of the data from the request input. Must be of the form:
              {"userId": int, "bookId":[int (goodreads_id)]}.
        Returns:
            tensor: Returns the tensor data of the input
        """
        body = data[0]['body']

        # TODO: Store book_ids (rating_id) in DB
        # Need book_ids the same as in Training so use goodreads_id to get book_ids
        df_idmap = self.df_idmap
        book_ids, goodreads_ids = [], []
        for gid in body['bookId']:
            bids = df_idmap[df_idmap['goodreads_id'] == gid]['book_id']
            if len(bids) == 0:
                continue
            book_ids.append(bids.iloc[0])
            goodreads_ids.append(gid)

        batch_size = len(goodreads_ids)
        # Making predictions for the same user across each book_id so expand
        # Throw away user. Will add in the actual user later as the workflow alters the userId
        uids = [-1]*batch_size
        # Throw away ratings
        ratings = [0]*batch_size

        df = pd.DataFrame({'user_id': uids, 
                           'book_id': book_ids, 
                           'rating': ratings})

        # TODO: Probably a faster way of transforming the ds without having to wrap in DL
        ds = TorchAsyncItr(
            self.workflow.transform(nvt.Dataset(df)),
            batch_size=batch_size,
            cats=['user_id', 'goodreads_id'],
            conts=["rating"]
        )
        dl = DLDataLoader(ds, batch_size=None, pin_memory=False, num_workers=0)
        data = next(iter(dl))

        user = (data[0]['user_id'] + body['userId']).to(self.device)
        media = data[0]['goodreads_id'].to(self.device)
        return (user, media)
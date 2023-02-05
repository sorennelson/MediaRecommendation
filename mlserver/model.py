import torch
import torch.nn as nn


class VanillaCF(nn.Module):
    def __init__(self, emb_size=12, n_users=154415, n_media=56964):
        super().__init__()
        self.user_emb = nn.Embedding(n_users, emb_size)
        self.media_emb = nn.Embedding(n_media, emb_size)

    def forward(self, user, media):
        return torch.sigmoid(self.user_emb(user) @ torch.transpose(self.media_emb(media), 1, 2))


class ProdVanillaCF(nn.Module):
    def __init__(self, prod_user_emb, train_media_emb):
        super().__init__()
        self.user_emb = nn.Embedding.from_pretrained(prod_user_emb, freeze=True)
        self.media_emb = nn.Embedding.from_pretrained(train_media_emb, freeze=True)

    def forward(self, user, media):
        return torch.sigmoid(self.user_emb(user) @ torch.transpose(self.media_emb(media), 1, 2))
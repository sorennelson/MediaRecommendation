# Media Recommendation
A media recommendation MacOS app that suggests new movies and books to users based on media they rate via Collaborative Filtering DNN's.

This is a sandbox for recommender system ideas I have that are completely decoupled from any business metrics.

If you have any ideas or feedback, please [reach out](sorennelson33@gmail.com).

![MediaRec](./Wide_Media_Rec.png)


## Models
### [Movies](./MovieRec.ipynb)

The current model is a simple 4 layer MLP with learned User/Movie Embeddings,
learned genre Multi-Hot embeddings, and a few extra scalar movie features. 

To efficiently adjust to new user preferences in production we use an 
Embeddings Cluster approach where the model user embeddings are first clustered
then the new user is mapped to the closest cluster centroid based on average cluster ratings.

Future Work:
- Fixed LLM embedding feature for genres and movie descriptions.
- Incorporating tags, reviews, and other features.

Data: 
- [MovieLens 25M Dataset](https://grouplens.org/datasets/movielens/25m/): 162,000 Users, 62,000 Movies from IMDB, 25M Ratings on a 0.5-5 star scale in half star increments.

### Books
The V2 Model is in the works.

Data: 
- [Goodbooks-10k Dataset](http://fastml.com/goodbooks-10k-a-new-dataset-for-book-recommendations/): 465 Users, 10,000 Books from GoodReads, 1,048,517 Ratings on a 1-5 scale in one star increments.

## System Architecture
The MacOS app is written in Swift. We use Django for the backend API, TorchServe to serve all ML models, and a PostgreSQL database. The Django and Torchserve services are deployed on Kubernetes clusters on GKE. The database lives in Amazon RDS.

## Future Work
- [ ] Related media suggestions
- [ ] Podcasts
- [ ] Spotify playlists
- [ ] Explore/Exploit manual adjustment
- [ ] Wish Lists

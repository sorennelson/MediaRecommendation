# Media Recommendation
A macOS application that uses rankings from MovieLens and Goodbooks datasets to recommend movies, and books to users via a Collaborative Filtering Algorithm.

## Datasets
[MovieLens Small Dataset](https://grouplens.org/datasets/movielens/) 
- 13,000 Users
- 10,000 Movies from IMDB
- 65,000 Ratings on a 0.5-5 star scale in half star increments 

[Goodbooks-10k Dataset](http://fastml.com/goodbooks-10k-a-new-dataset-for-book-recommendations/) 
- 465 Users
- 10,000 Books from GoodReads
- 1,048,517 Ratings on a 1-5 scale in one star increments

## Results
Data was trained using a random 90% of the data and validated using the other 10% of the ratings. Ratings were then combined to test the model for the following results.
- RMSE of 0.074 on MovieLens Data
- RMSE of 0.096 on GoodBooks Data

Detailed results may be viewed [HERE](https://github.com/sorennelson/MediaRecommendation/blob/master/Collaborative_Filtering_Results.ipynb).

## Future
- [ ] Add Music

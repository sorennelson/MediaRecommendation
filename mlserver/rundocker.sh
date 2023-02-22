# docker run --rm -it \
# -p 3000:8080 -p 3001:8081 \
# -v "$(pwd)/model_store":/home/model-server/model-store torchserve:1.0 \
# torchserve --start --model-store model-store --models movie=movie.mar

# docker run --rm -it \
# -p 3000:8080 -p 3001:8081 \
# -v "$(pwd)/model_store":/home/model-server/model-store us-east1-docker.pkg.dev/mystic-bank-375221/movies/movies:v1 \
# torchserve --start --model-store model-store --models movie=movie.mar

docker run --rm -it \
-p 3000:8080 -p 3001:8081 \
torchserve:1.3
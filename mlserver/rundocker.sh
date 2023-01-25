docker run --rm -it \
-p 3000:8080 -p 3001:8081 \
-v "$(pwd)/model_store":/home/model-server/model-store torchserve:1.0 \
torchserve --start --model-store model-store --models movie=movie.mar
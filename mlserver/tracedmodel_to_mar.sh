mkdir model_store

MEDIA=$1
case $MEDIA in
    movie)
        torch-model-archiver --model-name movie \
        --version 1.2 \
        --serialized-file ./curr_model/mlpgenre_cluster_4l128_32emb_1e-2lradam_0d_5e--02_02_23.pt \
        --extra-files "./workflow,./workflow/movie_workflow,./workflow/movie_workflow/categories,./requirements.txt,./media_handler.py" \
        --handler movie_handler.py  \
        --requirements-file ./requirements.txt \
        --export-path model_store -f 
        ;;
    book)
        torch-model-archiver --model-name book \
        --version 1.0 \
        --serialized-file ./curr_book_model/mlp_cluster500_4l_32emb_128h_1e-2lradam_0d_3e--book--02_20_23.pt \
        --extra-files "./workflow,./workflow/book_workflow,./workflow/book_workflow/categories,./requirements.txt,./media_handler.py" \
        --handler book_handler.py  \
        --requirements-file ./requirements.txt \
        --export-path model_store -f 
        ;;
    *)
        echo "Bad media type!"
        ;;
esac
mkdir model_store

torch-model-archiver --model-name movie \
--version 1.2 \
--serialized-file ./curr_model/mlpgenre_cluster_4l128_32emb_1e-2lradam_0d_5e--02_02_23.pt \
--extra-files "./workflow,./workflow/movie_workflow,./workflow/movie_workflow/categories,./requirements.txt" \
--handler handler.py  \
--requirements-file ./requirements.txt \
--export-path model_store -f 
mkdir model_store

torch-model-archiver --model-name movie \
--version 1.1 \
--serialized-file ./curr_model/mlpgenre_4l128_32emb_1e-2lradam_0d_5e_prodavg0--01_30_23.pt \
--extra-files "./workflow,./workflow/movie_workflow,./workflow/movie_workflow/categories,./requirements.txt" \
--handler handler.py  \
--requirements-file ./requirements.txt \
--export-path model_store -f 
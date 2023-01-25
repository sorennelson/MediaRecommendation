mkdir model_store

torch-model-archiver --model-name movie \
--version 1.0 \
--serialized-file ./cf_12emb_1e-2lradam_0d_5e_prodavg-0--01_23_25.pt \
--extra-files "./workflow,./workflow/movie_workflow,./workflow/movie_workflow/categories,./requirements.txt" \
--handler handler.py  \
--requirements-file ./requirements.txt \
--export-path model_store -f 
FROM continuumio/miniconda3:latest
EXPOSE 8000
WORKDIR /app 
COPY requirements.txt /app
COPY move_ml.sh /app
RUN pip install -r requirements.txt --no-cache-dir
RUN pip install nvtabular torch
COPY . /app 
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
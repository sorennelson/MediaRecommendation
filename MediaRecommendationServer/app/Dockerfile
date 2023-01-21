FROM frolvlad/alpine-miniconda3:python3.7
EXPOSE 8000
WORKDIR /app 
COPY requirements.txt /app
RUN pip install -r requirements.txt --no-cache-dir
COPY . /app 
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
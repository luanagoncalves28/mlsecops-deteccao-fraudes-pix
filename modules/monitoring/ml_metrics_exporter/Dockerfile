FROM python:3.10-slim

RUN pip install flask prometheus_client

COPY app.py /app/app.py

WORKDIR /app

EXPOSE 8080

CMD ["python", "app.py"]
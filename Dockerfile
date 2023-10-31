FROM python:3.7-slim
WORKDIR /app
RUN pip install flask pytest
COPY . /app
EXPOSE 5000
CMD ["python", "-u", "app.py"]
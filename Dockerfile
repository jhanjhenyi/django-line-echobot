FROM python:3.7.6-slim

LABEL maintainer="jhanjhenyi@gmail.com"

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libpq-dev

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY ./django_line_bot .

ENTRYPOINT ["python3", "manage.py"]
CMD ["runserver", "0.0.0.0:8000"]

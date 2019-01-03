FROM python:3.6

LABEL description="Run flask application."

EXPOSE 5000

RUN apt-get update
COPY requirements.txt /tmp
WORKDIR /tmp
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

RUN apt-get install -y build-essential
WORKDIR /usr/src/app

CMD [ "python", "-m", "flask", "run", "--host=0.0.0.0" ]

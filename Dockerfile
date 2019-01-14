FROM python:3.6

LABEL description="Run flask application."

EXPOSE 5000

RUN apt-get update
RUN apt-get install -y build-essential
RUN pip install --upgrade pip

WORKDIR /tmp
COPY requirements.txt /tmp
RUN pip install -r requirements.txt

WORKDIR /usr/src/app

CMD [ "python", "-m", "flask", "run", "--host=0.0.0.0" ]

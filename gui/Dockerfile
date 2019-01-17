FROM debian:stretch
MAINTAINER Karol Samborski <edv.karol@gmail.com>
RUN apt-get -y update && apt-get install -y curl git gnupg
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -y install nodejs
RUN npm install -g --unsafe elm elm-format elm-analyse elm-minify
VOLUME /app
WORKDIR /app
CMD ["/bin/bash"]


FROM golang

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y vim
RUN apt-get install -y nodejs

RUN go get -u -tags="testing debug" github.com/droghio/sia/...
RUN npm install sia.js

ADD error_log.sh ./
ADD bootstrap.sh ./
CMD ["bash", "bootstrap.sh"]

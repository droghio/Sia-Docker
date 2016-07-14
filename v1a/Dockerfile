FROM golang
RUN go get -u -tags="debug dev" github.com/droghio/sia/...
ADD bootstrap.sh ./
CMD ["bash", "bootstrap.sh"]

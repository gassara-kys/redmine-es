FROM golang:1.9.1 AS builder

RUN go get -v github.com/go-sql-driver/mysql && \
    go get -v github.com/jinzhu/gorm && \
    go get -v github.com/olivere/elastic
COPY *.go /go/src/github.com/gassara-kys/redmine-es/sync/
WORKDIR /go/src/github.com/gassara-kys/redmine-es/sync/
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/sync-redmine


# sync-redmine
FROM golang:1.9-alpine

COPY --from=builder /go/src/github.com/gassara-kys/redmine-es/sync/bin/ /usr/local/redmine-sync/bin/
ENV DB_HOST= \
    DB_PORT= \
    DB_NAME= \
    DB_USER= \
    DB_PASS= \
    ES_URL=
ENTRYPOINT ["/usr/local/redmine-sync/bin/sync-redmine"]
# BUILDER #################################
FROM	golang:1.11-alpine as builder

ENV 	CGO_ENABLED=0
ENV 	GOOS=linux
ENV 	GOARCH=amd64

ARG 	PACKAGE_NAME=github.com/kawamuray/prometheus-json-exporter

RUN 	apk update && apk add git bash && \
				go get -u github.com/golang/dep/... && \
				mkdir -p /go/src/$PACKAGE_NAME && \
				git clone https://${PACKAGE_NAME}.git /go/src/$PACKAGE_NAME

COPY	Gopkg.toml Gopkg.lock /go/src/$PACKAGE_NAME/

RUN		set -ex && \
				cd /go/src/$PACKAGE_NAME && \
				dep ensure -vendor-only && \
				go install $PACKAGE_NAME && \
				go build -o /root/json_exporter .

# ACTUAL IMAGE ############################
FROM 	alpine

COPY 	--from=builder /root/json_exporter /usr/bin
VOLUME	["/config"]
ENV 	EXPORTER_PORT=7979
ENV		EXPORTER_SCRAPE_INTERVAL_SEC=60

CMD 	json_exporter --port $EXPORTER_PORT --interval $EXPORTER_SCRAPE_INTERVAL_SEC $EXPORTER_URL $EXPORTER_CONFIG

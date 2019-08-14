.EXPORT_ALL_VARIABLES:
APP_VERSION     = $(shell git describe --abbrev=0 --tags)
APP_NAME        = prom-json-exporter
DOCKER_ID_USER  = dmi7ry

.ONESHELL:

all: build

build:
	docker build --squash -t $(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION) .
build-nc:
	docker build --squash --no-cache -t $(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION) .
build-latest:
	docker build --squash -t $(DOCKER_ID_USER)/$(APP_NAME):latest .
build-today:
	docker build --squash -t $(DOCKER_ID_USER)/$(APP_NAME):`date +"%Y%m%d"` .

push:
	docker push $(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION)
push-latest:
	docker push $(DOCKER_ID_USER)/$(APP_NAME):latest
push-today:
	docker push $(DOCKER_ID_USER)/$(APP_NAME):`date +"%Y%m%d"`

publish: build build-latest build-today push push-latest push-today

serve-json:
	python3 -m http.server 8000 &
run:
	docker rm -f $(APP_NAME) && \
	docker run --rm -d --name $(APP_NAME) \
		-e "URL=http://127.0.0.1:8000/example/data.json" \
		-p 8001:7979 \
		-v `pwd`/example:/config \
		$(DOCKER_ID_USER)/$(APP_NAME):$(APP_VERSION)

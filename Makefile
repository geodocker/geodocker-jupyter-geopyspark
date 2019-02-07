.PHONY: image clean cleaner cleanest mrproper

TAG ?= 8
FAMILY := quay.io/geodocker/jupyter-geopyspark
IMAGE := $(FAMILY):$(TAG)
GEOPYSPARK_SHA ?= a75dda65434b472045f3fd97baca1e9bdc1ac353
GEOPYSPARK_VERSION ?= 0.4.2

all: image

image: Dockerfile
	docker build \
          --build-arg GEOPYSPARK_VERSION=$(GEOPYSPARK_VERSION) \
          --build-arg GEOPYSPARKSHA=$(GEOPYSPARK_SHA) \
          -t $(IMAGE) -f Dockerfile .

clean:

cleaner: clean

cleanest: cleaner

mrproper: cleanest

publish:
	docker tag $(IMAGE) "$(FAMILY):latest"
	docker push $(IMAGE)
	docker push "$(FAMILY):latest"

run:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 -p 4040:4040 \
          $(EXTRA_FLAGS) \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(IMAGE)

run-editable:
	mkdir -p $(HOME)/.aws
	docker run -it --rm --name geopyspark \
          -p 8000:8000 -p 4040:4040 \
          $(EXTRA_FLAGS) \
          -v $(GEOPYSPARK_DIR):/home/hadoop/.local/lib/python3.4/site-packages/geopyspark:rw \
          -v $(shell pwd)/notebooks:/home/hadoop/notebooks:rw \
          -v $(HOME)/.aws:/home/hadoop/.aws:ro \
          $(IMAGE)

shell:
	docker exec -it geopyspark bash

.PHONY: image clean cleaner cleanest mrproper

TAG ?= new
FAMILY := quay.io/geodocker/jupyter-geopyspark
AWSBUILD := $(FAMILY):aws-build-gdal-4
IMAGE := $(FAMILY):$(TAG)
GEOPYSPARK_SHA ?= ce5e03f7210966d893129311d1dd5b3945075bf7
GEONOTEBOOK_SHA ?= 2c0073c60afc610f7d9616edbb3843e5ba8b68af
GEOPYSPARK_VERSION ?= 0.3.0
PYTHON_BLOB1 := friends-of-geopyspark.tar.gz
PYTHON_BLOB2 := geopyspark-sans-friends.tar.gz

all: image

blobs/%: archives/%
	cp -f $< $@

archives/$(PYTHON_BLOB1): scripts/build-python-blob1.sh
	rm -rf scratch/pip-cache/wheels/*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/pip-cache:/root/.cache/pip:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(AWSBUILD) /scripts/build-python-blob1.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB1)

archives/$(PYTHON_BLOB2): scripts/build-python-blob2.sh
	rm -rf scratch/pip-cache/wheels/*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(AWSBUILD) /scripts/build-python-blob2.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB2) $(GEOPYSPARK_SHA)

image: Dockerfile blobs/$(PYTHON_BLOB1) blobs/$(PYTHON_BLOB2)
ifeq ($(TRAVIS),1)
	docker rmi $(AWSBUILD)
	rm -rf archives/ scratch/local/
endif
	docker build \
          --build-arg VERSION=$(GEOPYSPARK_VERSION) \
          --build-arg GEONOTEBOOKSHA=$(GEONOTEBOOK_SHA) \
          --build-arg PYTHONBLOB1=$(PYTHON_BLOB1) \
          --build-arg PYTHONBLOB2=$(PYTHON_BLOB2) \
          -t $(IMAGE) -f Dockerfile .

clean:
	rm -rf scratch/local/gdal/

cleaner: clean
	rm -f blobs/*
	rm -rf scratch/dot-local/*

cleanest: cleaner
	rm -rf scratch/local/src

mrproper: cleanest
	rm -rf archives/*
	rm -rf scratch/pip-cache/*

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

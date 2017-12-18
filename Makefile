.PHONY: image clean cleaner cleanest mrproper

TAG ?= rpm
FAMILY := quay.io/geodocker/jupyter-geopyspark
AWSBUILD := $(FAMILY):aws-build-gdal-3
IMAGE := $(FAMILY):$(TAG)
GEOPYSPARK_SHA ?= 7b93a0264674513d6f8923c43c32c82f056e5f10
GEOPYSPARK_NETCDF_SHA ?= f48dd2119d3440c7b800c8c60f3cd4d0724645ab
GEONOTEBOOK_SHA ?= 2c0073c60afc610f7d9616edbb3843e5ba8b68af
GEOPYSPARK_VERSION ?= 0.3.0
PYTHON_BLOB1 := friends-of-geopyspark.tar.gz
PYTHON_BLOB2 := geopyspark-sans-friends.tar.gz

all: image

blobs/%: archives/%
	cp -f $< $@

########################################################################

archives/$(PYTHON_BLOB1) scratch/dot-local/lib/python3.4/site-packages/.xxx: scripts/build-python-blob1.sh
	rm -rf scratch/dot-local/lib/python3.4/site-packages/*
	rm -rf scratch/pip-cache/wheels/*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scratch/pip-cache:/root/.cache/pip:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(AWSBUILD) /scripts/build-python-blob1.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB1)

archives/$(PYTHON_BLOB2): scripts/build-python-blob2.sh scratch/dot-local/lib/python3.4/site-packages/.xxx
	rm -rf scratch/dot-local/lib/python3.4/site-packages/geopyspark*
	rm -rf scratch/pip-cache/wheels/*
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scratch/dot-local:/root/.local:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(AWSBUILD) /scripts/build-python-blob2.sh $(shell id -u) $(shell id -g) $(PYTHON_BLOB2) $(GEOPYSPARK_SHA) $(GEOPYSPARK_NETCDF_SHA)

########################################################################

image: Dockerfile \
   blobs/$(PYTHON_BLOB1) \
   blobs/$(PYTHON_BLOB2)
ifeq ($(TRAVIS),1)
	docker rmi $(AWSBUILD)
	rm -rf $(shell ls archives/* | grep -iv 'netcdf')
	rm -rf geopyspark-*/ scratch/local/
endif
	docker build \
          --build-arg VERSION=$(GEOPYSPARK_VERSION) \
          --build-arg GEONOTEBOOKSHA=$(GEONOTEBOOK_SHA) \
          --build-arg PYTHONBLOB1=$(PYTHON_BLOB1) \
          --build-arg PYTHONBLOB2=$(PYTHON_BLOB2) \
          -t $(IMAGE) -f Dockerfile .

########################################################################
env:
	env

clean:
	rm -f archives/$(GEOPYSPARK_JAR)
	rm -rf scratch/local/gdal/

cleaner: clean
	rm -f blobs/*
	rm -rf geopyspark-*/
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

########################################################################

GEOPYSPARK_DIR ?= $(realpath ../geopyspark/geopyspark)

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

archives/node-v8.5.0.tar.gz:
	curl -L "https://nodejs.org/dist/v8.5.0/node-v8.5.0.tar.gz" -o $@

archives/nodejs-8.5.0-13.x86_64.rpm: rpmbuild/SPECS/nodejs.spec scripts/nodejs.sh $(shell scripts/not.sh archives/rpmbuild.tar) archives/node-v8.5.0.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/nodejs.sh $(shell id -u) $(shell id -g)

archives/jupyterhub-0.7.2-13.x86_64.rpm: rpmbuild/SPECS/jupyterhub.spec scripts/jupyterhub.sh $(shell scripts/not.sh archives/rpmbuild.tar) archives/jupyterhub.tar archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip archives/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm archives/nodejs-8.5.0-13.x86_64.rpm
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/jupyterhub.sh $(shell id -u) $(shell id -g) geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm

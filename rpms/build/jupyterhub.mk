rpmbuild/SOURCES/node-v8.5.0.tar.gz:
	curl -L "https://nodejs.org/dist/v8.5.0/node-v8.5.0.tar.gz" -o $@

archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip:
	curl -L "https://github.com/ipython/ipykernel/archive/629ac54cae9767310616d47d769665453619ac64.zip" -o $@

rpmbuild/SOURCES/jupyterhub.tar:
	tar cvf $@ jupyterhub/

jupyterhub-deps: archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip rpmbuild/SOURCES/jupyterhub.tar

rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm: rpmbuild/SPECS/nodejs.spec scripts/nodejs.sh rpmbuild/SOURCES/node-v8.5.0.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/nodejs.sh $(shell id -u) $(shell id -g)

rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm: rpmbuild/SPECS/jupyterhub.spec \
scripts/jupyterhub.sh \
rpmbuild/SOURCES/jupyterhub.tar \
archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip \
$(shell scripts/not.sh rpmbuild/RPMS/x86_64/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm) \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm
	docker run -it --rm \
	  -v $(shell pwd)/archives:/archives:ro \
	  -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/jupyterhub.sh $(shell id -u) $(shell id -g) geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm

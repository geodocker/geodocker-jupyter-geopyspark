rpmbuild/SOURCES/node-v8.5.0.tar.gz:
	curl -L "https://nodejs.org/dist/v8.5.0/node-v8.5.0.tar.gz" -o $@

archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip:
	curl -L "https://github.com/ipython/ipykernel/archive/629ac54cae9767310616d47d769665453619ac64.zip" -o $@

archives/ipykernel.zip: archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip jupyterhub/patch.diff
	rm -rf ipykernel-629ac54cae9767310616d47d769665453619ac64/
	unzip $<
	cd ipykernel-629ac54cae9767310616d47d769665453619ac64; patch -p1 < ../jupyterhub/patch.diff
	zip $@ $(shell find ipykernel-629ac54cae9767310616d47d769665453619ac64)
	rm -r ipykernel-629ac54cae9767310616d47d769665453619ac64/

rpmbuild/SOURCES/jupyterhub.tar: jupyterhub/
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
rpmbuild/RPMS/x86_64/geopyspark-deps-0.0.0-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm
	docker run -it --rm \
	  -v $(shell pwd)/archives:/archives:ro \
	  -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/jupyterhub.sh $(shell id -u) $(shell id -g)

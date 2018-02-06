rpmbuild/SOURCES/node-v8.5.0.tar.gz:
	curl -L "https://nodejs.org/dist/v8.5.0/node-v8.5.0.tar.gz" -o $@

archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip:
	curl -L "https://github.com/ipython/ipykernel/archive/629ac54cae9767310616d47d769665453619ac64.zip" -o $@

archives/ipykernel.zip: archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip \
patches/patch.diff
	rm -rf ipykernel-629ac54cae9767310616d47d769665453619ac64/
	unzip $<
	cd ipykernel-629ac54cae9767310616d47d769665453619ac64; patch -p1 < ../patches/patch.diff
	zip -r $@ ipykernel-629ac54cae9767310616d47d769665453619ac64/
	rm -r ipykernel-629ac54cae9767310616d47d769665453619ac64/

rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm: rpmbuild/SPECS/nodejs.spec \
scripts/nodejs.sh \
rpmbuild/SOURCES/node-v8.5.0.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/nodejs.sh $(shell id -u) $(shell id -g)

rpmbuild/RPMS/x86_64/configurable-http-proxy-0.0.0-13.x86_64.rpm: rpmbuild/SPECS/configurable-http-proxy.spec \
scripts/configurable-http-proxy.sh \
rpmbuild/SOURCES/configurable-http-proxy.tar \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:ro \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/configurable-http-proxy.sh $(shell id -u) $(shell id -g)

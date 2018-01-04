archives/geonotebook-$(GEONOTEBOOK_SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK_SHA).zip" -o $@

rpmbuild/SOURCES/geonotebook.tar:
	tar cvf $@ geonotebook/

geonotebook-deps: archives/geonotebook-$(GEONOTEBOOK_SHA).zip rpmbuild/SOURCES/geonotebook.tar

rpmbuild/RPMS/x86_64/geonotebook-0.0.0-13.x86_64.rpm: rpmbuild/SPECS/geonotebook.spec scripts/geonotebook.sh \
rpmbuild/SOURCES/geonotebook.tar \
$(shell scripts/not.sh rpmbuild/RPMS/x86_64/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm) \
rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm \
rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm \
archives/geonotebook-$(GEONOTEBOOK_SHA).zip
	cp -f archives/geonotebook-$(GEONOTEBOOK_SHA).zip archives/geonotebook.zip
	docker run -it --rm \
	  -v $(shell pwd)/archives:/archives:ro \
	  -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/geonotebook.sh $(shell id -u) $(shell id -g) geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm
	rm -f archives/geonotebook.zip

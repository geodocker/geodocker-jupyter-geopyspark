archives/geonotebook-$(GEONOTEBOOK_SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK_SHA).zip" -o $@

archives/geonotebook-0.0.0-13.x86_64.rpm: rpmbuild/SPECS/geonotebook.spec scripts/geonotebook.sh $(shell scripts/not.sh archives/rpmbuild.tar) archives/geonotebook.tar \
archives/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm \
archives/nodejs-8.5.0-13.x86_64.rpm archives/jupyterhub-0.7.2-13.x86_64.rpm \
archives/freetype2-2.8-33.x86_64.rpm archives/proj493-4.9.3-33.x86_64.rpm archives/gdal213-2.1.3-33.x86_64.rpm \
archives/boost162-lib-1_62_0-33.x86_64.rpm archives/mapnik-093fcee-33.x86_64.rpm archives/python-mapnik-e5f107d-33.x86_64.rpm \
archives/geonotebook-$(GEONOTEBOOK_SHA).zip
	cp -f archives/geonotebook-$(GEONOTEBOOK_SHA).zip archives/geonotebook.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/geonotebook.sh $(shell id -u) $(shell id -g) geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm
	rm -f archives/geonotebook.zip

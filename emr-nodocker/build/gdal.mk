archives/proj-4.9.3.tar.gz:
	curl -L "http://download.osgeo.org/proj/proj-4.9.3.tar.gz" -o $@

archives/freetype-2.8.tar.gz:
	curl -L "https://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.gz" -o $@

archives/gdal-2.1.3.tar.gz:
	curl -L "http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz" -o $@

archives/proj493-4.9.3-33.x86_64.rpm archives/proj493-lib-4.9.3-33.x86_64.rpm: rpmbuild/SPECS/proj.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/proj-4.9.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/proj.sh $(shell id -u) $(shell id -g)

archives/freetype2-2.8-33.x86_64.rpm archives/freetype2-lib-2.8-33.x86_64.rpm: rpmbuild/SPECS/freetype.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/freetype-2.8.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/freetype.sh $(shell id -u) $(shell id -g)

archives/gdal213-2.1.3-33.x86_64.rpm archives/gdal213-lib-2.1.3-33.x86_64.rpm: rpmbuild/SPECS/gdal.spec $(shell scripts/not.sh archives/rpmbuild.tar) archives/proj493-4.9.3-33.x86_64.rpm archives/gdal-2.1.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/gdal.sh $(shell id -u) $(shell id -g)

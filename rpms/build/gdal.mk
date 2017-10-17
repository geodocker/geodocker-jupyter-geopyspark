rpmbuild/SOURCES/proj-4.9.3.tar.gz:
	curl -L "http://download.osgeo.org/proj/proj-4.9.3.tar.gz" -o $@

rpmbuild/SOURCES/freetype-2.8.tar.gz:
	curl -L "https://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.gz" -o $@

rpmbuild/SOURCES/gdal-2.1.3.tar.gz:
	curl -L "http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz" -o $@

rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm: rpmbuild/SPECS/proj.spec rpmbuild/SOURCES/proj-4.9.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/proj.sh $(shell id -u) $(shell id -g)

rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm rpmbuild/RPMS/x86_64/freetype2-lib-2.8-33.x86_64.rpm: rpmbuild/SPECS/freetype.spec rpmbuild/SOURCES/freetype-2.8.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/freetype.sh $(shell id -u) $(shell id -g)

rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/gdal213-lib-2.1.3-33.x86_64.rpm: rpmbuild/SPECS/gdal.spec rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm rpmbuild/SOURCES/gdal-2.1.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/gdal.sh $(shell id -u) $(shell id -g)

rpmbuild/SOURCES/boost_1_62_0.tar.bz2:
	curl -L "https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.bz2" -o $@

rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz:
	curl -L "https://github.com/mapbox/variant/archive/v1.1.3.tar.gz" -o $@

rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz:
	curl -L "https://github.com/mapbox/geometry.hpp/archive/v0.9.2.tar.gz" -o $@

rpmbuild/SOURCES/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip:
	curl -L "https://github.com/mapnik/mapnik/archive/093fcee6d1ba1fd360718ceade83894aeffc2548.zip" -o $@

rpmbuild/SOURCES/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip:
	curl -L "https://github.com/mapnik/python-mapnik/archive/e5f107d8d459590829d50c976c7a4222d8f4737c.zip" -o $@

rpmbuild/RPMS/x86_64/boost162-1_62_0-33.x86_64.rpm rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm: rpmbuild/SPECS/boost162.spec rpmbuild/SOURCES/boost_1_62_0.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/boost162.sh $(shell id -u) $(shell id -g)

rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm: rpmbuild/SPECS/mapnik.spec rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm rpmbuild/RPMS/x86_64/boost162-1_62_0-33.x86_64.rpm rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz rpmbuild/SOURCES/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/mapnik.sh $(shell id -u) $(shell id -g)

rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm: rpmbuild/SPECS/python-mapnik.spec rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz rpmbuild/SOURCES/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/python-mapnik.sh $(shell id -u) $(shell id -g)

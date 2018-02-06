wheels: archives/ipykernel.zip \
rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/boost162-1_62_0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm \
rpmbuild/SOURCES/mapbox-geometry-v0.9.2.tar.gz \
rpmbuild/SOURCES/mapbox-variant-v1.1.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:ro \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:ro \
          -v $(shell pwd)/wheel:/wheel:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/wheel.sh $(shell id -u) $(shell id -g)

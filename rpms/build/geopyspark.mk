archives/geopyspark-$(GEOPYSPARK_SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK_SHA).zip" -o $@

archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip:
	curl -L "https://github.com/geotrellis/geopyspark-netcdf/archive/$(GEOPYSPARK_NETCDF_SHA).zip" -o $@

rpmbuild/SOURCES/geopyspark.tar:
	tar cvf $@ geopyspark/

rpmbuild/RPMS/x86_64/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm rpmbuild/RPMS/x86_64/geopyspark-worker-$(GEOPYSPARK_VERSION)-13.x86_64.rpm: rpmbuild/SPECS/geopyspark.spec scripts/geopyspark.sh rpmbuild/SOURCES/geopyspark.tar \
archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR)
	cp -f archives/geopyspark-netcdf-$(GEOPYSPARK_NETCDF_SHA).zip archives/geopyspark-netcdf.zip
	cp -f archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:ro \
	  -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/geopyspark.sh $(shell id -u) $(shell id -g)
	rm -f archives/geopyspark.zip
	rm -f archives/geopyspark-netcdf.zip

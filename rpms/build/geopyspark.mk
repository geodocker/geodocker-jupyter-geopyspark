rpmbuild/SOURCES/geopyspark.tar: geopyspark/
	tar cvf $@ geopyspark/

rpmbuild/RPMS/x86_64/geopyspark-deps-0.0.0-13.x86_64.rpm: rpmbuild/SPECS/geopyspark.spec \
scripts/geopyspark.sh rpmbuild/SOURCES/geopyspark.tar
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:ro \
	  -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/geopyspark.sh $(shell id -u) $(shell id -g)

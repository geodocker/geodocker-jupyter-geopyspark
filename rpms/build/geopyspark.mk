GEOPYSPARK_JAR := geotrellis-backend-assembly-$(GEOPYSPARK_VERSION).jar
NETCDF_JAR := gddp-assembly-$(GEOPYSPARK_VERSION).jar
CDM_JAR := netcdfAll-5.0.0-SNAPSHOT.jar

archives/s3+hdfs.zip:
	curl -L "https://github.com/Unidata/thredds/archive/feature/s3+hdfs.zip" -o $@

archives/geopyspark-$(GEOPYSPARK_SHA).zip:
	curl -L "https://github.com/locationtech-labs/geopyspark/archive/$(GEOPYSPARK_SHA).zip" -o $@

archives/geopyspark-netcdf-$(NETCDF_SHA).zip:
	Curl -L "https://github.com/geotrellis/geopyspark-netcdf/archive/$(NETCDF_SHA).zip" -o $@

rpmbuild/SOURCES/geopyspark.tar:
	tar cvf $@ geopyspark/

archives/$(CDM_JAR): scripts/netcdf-jar.sh archives/s3+hdfs.zip
	docker run -it --rm \
           -v $(shell pwd)/archives:/archives:rw \
           -v $(shell pwd)/scripts:/scripts:ro \
           -v $(HOME)/.m2:/root/.m2:rw \
           -v $(HOME)/.gradle:/root/.gradle:rw \
           openjdk:8-jdk /scripts/netcdf-jar.sh $(shell id -u) $(shell id -g) $(CDM_JAR)

archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR): scripts/geopyspark-jar.sh archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark-netcdf-$(NETCDF_SHA).zip archives/$(CDM_JAR)
	docker run -it --rm \
           -v $(shell pwd)/archives:/archives:rw \
           -v $(shell pwd)/scripts:/scripts:ro \
           -v $(HOME)/.m2:/root/.m2:rw \
           -v $(HOME)/.ivy2:/root/.ivy2:rw \
           openjdk:8-jdk /scripts/geopyspark-jar.sh $(shell id -u) $(shell id -g) \
	   $(GEOPYSPARK_SHA) $(GEOPYSPARK_JAR) $(NETCDF_SHA) $(NETCDF_JAR)

rpmbuild/RPMS/x86_64/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm rpmbuild/RPMS/x86_64/geopyspark-worker-$(GEOPYSPARK_VERSION)-13.x86_64.rpm: rpmbuild/SPECS/geopyspark.spec scripts/geopyspark.sh rpmbuild/SOURCES/geopyspark.tar \
archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark-netcdf-$(NETCDF_SHA).zip archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR)
	cp -f archives/geopyspark-netcdf-$(NETCDF_SHA).zip archives/geopyspark-netcdf.zip
	cp -f archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:ro \
	  -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/geopyspark.sh $(shell id -u) $(shell id -g)
	rm -f archives/geopyspark.zip
	rm -f archives/geopyspark-netcdf.zip

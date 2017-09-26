archives/geonotebook-$(GEONOTEBOOK_SHA).zip:
	curl -L "https://github.com/geotrellis/geonotebook/archive/$(GEONOTEBOOK_SHA).zip" -o $@

# archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR): scripts/geopyspark-jar.sh archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark-netcdf-$(NETCDF_SHA).zip archives/$(CDM_JAR)
# 	docker run -it --rm \
#            -v $(shell pwd)/archives:/archives:rw \
#            -v $(shell pwd)/scripts:/scripts:ro \
#            -v $(HOME)/.m2:/root/.m2:rw \
#            -v $(HOME)/.ivy2:/root/.ivy2:rw \
#            openjdk:8-jdk /scripts/geopyspark-jar.sh $(shell id -u) $(shell id -g) \
# 	   $(GEOPYSPARK_SHA) $(GEOPYSPARK_JAR) $(NETCDF_SHA) $(NETCDF_JAR)

# archives/geopyspark-$(GEOPYSPARK_VERSION)-13.x86_64.rpm archives/geopyspark-worker-$(GEOPYSPARK_VERSION)-13.x86_64.rpm: rpmbuild/SPECS/geopyspark.spec scripts/geopyspark.sh $(shell scripts/not.sh archives/rpmbuild.tar) archives/geopyspark.tar archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark-netcdf-$(NETCDF_SHA).zip archives/$(GEOPYSPARK_JAR) archives/$(NETCDF_JAR)
# 	cp -f archives/geopyspark-netcdf-$(NETCDF_SHA).zip archives/geopyspark-netcdf.zip
# 	cp -f archives/geopyspark-$(GEOPYSPARK_SHA).zip archives/geopyspark.zip
# 	docker run -it --rm \
#           -v $(shell pwd)/archives:/archives:rw \
#           -v $(shell pwd)/scripts:/scripts:ro \
#           $(GCC4IMAGE) /scripts/geopyspark.sh $(shell id -u) $(shell id -g)
# 	rm -f archives/geopyspark.zip
# 	rm -f archives/geopyspark-netcdf.zip

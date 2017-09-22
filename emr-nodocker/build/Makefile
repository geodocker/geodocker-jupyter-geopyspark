.PHONY: all centos-build-base centos-build-gcc6 aws-build-base aws-build-gdal base

FAMILY := quay.io/geodocker/emr-build
VERSION := 0
GCC4IMAGE := $(FAMILY):gcc4-$(VERSION)
GCC6IMAGE := $(FAMILY):gcc6-$(VERSION)

all: blobs/gdal-and-friends.tar.gz \
   blobs/gcc6-lib-6.4.0-33.x86_64.rpm \
   blobs/freetype2-lib-2.8-33.x86_64.rpm \
   blobs/boost162-lib-1_62_0-33.x86_64.rpm \
   blobs/gdal213-lib-2.1.3-33.x86_64.rpm \
   blobs/mapnik-093fcee-33.x86_64.rpm \
   blobs/python-mapnik-e5f107d-33.x86_64.rpm

blobs/%: archives/%
	cp -f $< $@

gcc4:
	docker build -t "$(FAMILY):$@-$(VERSION)" -f Dockerfile.$@ .

gcc6: blobs/gcc6-6.4.0-33.x86_64.rpm
	docker build -t "$(FAMILY):$@-$(VERSION)" -f Dockerfile.$@ .

########################################################################

archives/zlib-1.2.11.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz?r=http%3A%2F%2Fwww.zlib.net%2F&ts=1490316463&use_mirror=pilotfiber" -o $@

archives/libpng-1.6.30.tar.xz:
	curl -L "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.30/libpng-1.6.30.tar.xz?r=http%3A%2F%2Fwww.libpng.org%2Fpub%2Fpng%2Flibpng.html&ts=1502829944&use_mirror=iweb" -o $@

archives/geos-3.6.1.tar.bz2:
	curl -L "http://download.osgeo.org/geos/geos-3.6.1.tar.bz2" -o $@

archives/proj-4.9.3.tar.gz:
	curl -L "http://download.osgeo.org/proj/proj-4.9.3.tar.gz" -o $@

archives/lcms2-2.8.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/lcms/lcms/2.8/lcms2-2.8.tar.gz?r=&ts=1490316968&use_mirror=pilotfiber" -o $@

archives/openjpeg-v2.1.2.tar.gz:
	curl -L "https://github.com/uclouvain/openjpeg/archive/v2.1.2.tar.gz" -o $@

archives/gdal-2.1.3.tar.gz:
	curl -L "http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz" -o $@

########################################################################

archives/isl-0.16.1.tar.bz2:
	curl -L "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2" -o $@

archives/gcc-6.4.0.tar.xz:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-6.4.0/gcc-6.4.0.tar.xz" -o $@

archives/boost_1_62_0.tar.bz2:
	curl -L "https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.bz2" -o $@

archives/freetype-2.8.tar.gz:
	curl -L "https://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.gz" -o $@

archives/mapbox-variant-v1.1.3.tar.gz:
	curl -L "https://github.com/mapbox/variant/archive/v1.1.3.tar.gz" -o $@

archives/mapbox-geometry-v0.9.2.tar.gz:
	curl -L "https://github.com/mapbox/geometry.hpp/archive/v0.9.2.tar.gz" -o $@

archives/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip:
	curl -L "https://github.com/mapnik/mapnik/archive/093fcee6d1ba1fd360718ceade83894aeffc2548.zip" -o $@

archives/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip:
	curl -L "https://github.com/mapnik/python-mapnik/archive/e5f107d8d459590829d50c976c7a4222d8f4737c.zip" -o $@

########################################################################

archives/rpmbuild.tar: rpmbuild/
	tar cvf $@ $<

archives/gcc6-6.4.0-33.x86_64.rpm archives/gcc6-lib-6.4.0-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) $(shell scripts/not.sh archives/gcc-6.4.0.tar.xz) $(shell scripts/not.sh archives/isl-0.16.1.tar.bz2)
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC4IMAGE) /scripts/gcc6.sh $(shell id -u) $(shell id -g)

archives/boost162-1_62_0-33.x86_64.rpm archives/boost162-lib-1_62_0-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost_1_62_0.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/boost162.sh $(shell id -u) $(shell id -g)

archives/freetype2-2.8-33.x86_64.rpm archives/freetype2-lib-2.8-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/freetype-2.8.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/freetype.sh $(shell id -u) $(shell id -g)

archives/gdal213-2.1.3-33.x86_64.rpm archives/gdal213-lib-2.1.3-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/gdal-2.1.3.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/gdal.sh $(shell id -u) $(shell id -g)

archives/mapnik-093fcee-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/freetype2-2.8-33.x86_64.rpm archives/boost162-1_62_0-33.x86_64.rpm archives/gdal213-2.1.3-33.x86_64.rpm archives/mapbox-geometry-v0.9.2.tar.gz archives/mapbox-variant-v1.1.3.tar.gz archives/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/mapnik.sh $(shell id -u) $(shell id -g)

archives/python-mapnik-e5f107d-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/freetype2-2.8-33.x86_64.rpm archives/boost162-lib-1_62_0-33.x86_64.rpm archives/gdal213-2.1.3-33.x86_64.rpm archives/mapnik-093fcee-33.x86_64.rpm archives/mapbox-geometry-v0.9.2.tar.gz archives/mapbox-variant-v1.1.3.tar.gz archives/python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/python-mapnik.sh $(shell id -u) $(shell id -g)

########################################################################

archives/gdal-and-friends.tar.gz: $(shell scripts/not.sh scripts/build-gdal.sh) \
   archives/gdal-2.1.3.tar.gz \
   archives/geos-3.6.1.tar.bz2 \
   archives/lcms2-2.8.tar.gz \
   archives/libpng-1.6.30.tar.xz \
   archives/proj-4.9.3.tar.gz \
   archives/openjpeg-v2.1.2.tar.gz \
   archives/zlib-1.2.11.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(FAMILY):aws-build-base /scripts/build-gdal.sh $(shell id -u) $(shell id -g)

########################################################################

clean:
	rm -f archives/*debug*.rpm

cleaner: clean
	rm -f archives/rpmbuild.tar

cleanest: cleaner
	rm -f archives/[^g]*.rpm

mrproper: cleanest
	rm -f archives/*.tar.gz archives/*.tar.bz2 archives/*.tar.xz archives/*.zip

.PHONY: all centos-build-base centos-build-gcc6 aws-build-base aws-build-gdal base

all: centos-build-base centos-build-gcc6 aws-build-base aws-build-gdal base

blobs/%: archives/%
	cp -f $< $@

centos-build-base aws-build-base:
	docker build -t jamesmcclain/jupyter-geopyspark:$@ -f Dockerfile.$@ .

centos-build-gcc6: blobs/gcc-6.4.0-33.x86_64.rpm
	docker build -t jamesmcclain/jupyter-geopyspark:$@ -f Dockerfile.$@ .

aws-build-gdal: blobs/gdal-and-friends.tar.gz
	docker build -t jamesmcclain/jupyter-geopyspark:$@ -f Dockerfile.$@ .

base: blobs/gdal-and-friends.tar.gz \
   blobs/gcc-lib-6.4.0-33.x86_64.rpm \
   blobs/freetype-lib-2.8-33.x86_64.rpm \
   blobs/boost-lib-1_62_0-33.x86_64.rpm \
   blobs/mapnik-093fcee-33.x86_64.rpm \
   blobs/mapnik-python-e5f107d-33.x86_64.rpm
	docker build -t jamesmcclain/jupyter-geopyspark:base -f Dockerfile.base .

########################################################################

archives/zlib-1.2.11.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz?r=http%3A%2F%2Fwww.zlib.net%2F&ts=1490316463&use_mirror=pilotfiber" -o $@

archives/libpng-1.6.28.tar.gz:
	curl -L "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.28/libpng-1.6.28.tar.gz?r=http%3A%2F%2Fwww.libpng.org%2Fpub%2Fpng%2Flibpng.html&ts=1490316660&use_mirror=superb-sea2" -o $@

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

archives/v3.0.13.tar.gz:
	curl -L "https://github.com/mapnik/python-mapnik/archive/v3.0.13.tar.gz" -o $@

archives/mapnik-v3.0.13.tar.bz2:
	curl -L "https://github.com/mapnik/mapnik/releases/download/v3.0.13/mapnik-v3.0.13.tar.bz2" -o $@

archives/mapnik-a682cea51e7dd85815f20f5a107c4e6272dc01a9.zip:
	curl -L "https://github.com/mapnik/mapnik/archive/a682cea51e7dd85815f20f5a107c4e6272dc01a9.zip" -o $@

archives/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip:
	curl -L "https://github.com/mapnik/mapnik/archive/093fcee6d1ba1fd360718ceade83894aeffc2548.zip" -o $@

archives/mapnik-python-e5f107d8d459590829d50c976c7a4222d8f4737c.zip:
	curl -L "https://github.com/mapnik/python-mapnik/archive/e5f107d8d459590829d50c976c7a4222d8f4737c.zip" -o $@

archives/mapbox-variant-v1.1.3.tar.gz:
	curl -L "https://github.com/mapbox/variant/archive/v1.1.3.tar.gz" -o $@

archives/mapbox-geometry-v0.9.2.tar.gz:
	curl -L "https://github.com/mapbox/geometry.hpp/archive/v0.9.2.tar.gz" -o $@

archives/freetype-2.8.tar.gz:
	curl -L "https://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.gz" -o $@

archives/boost_1_64_0.tar.bz2:
	curl -L "https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.bz2" -o $@

archives/boost_1_62_0.tar.bz2:
	curl -L "https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.bz2" -o $@

archives/boost_1_58_0.tar.bz2:
	curl -L "http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2" -o $@

archives/boost_1_59_0.tar.bz2:
	curl -L "http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.bz2" -o $@

archives/gcc-7.1.0.tar.bz2:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-7.1.0/gcc-7.1.0.tar.bz2" -o $@

archives/gcc-6.4.0.tar.xz:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-6.4.0/gcc-6.4.0.tar.xz" -o $@

archives/gcc-5.4.0.tar.bz2:
	curl -L "http://www.netgull.com/gcc/releases/gcc-5.4.0/gcc-5.4.0.tar.bz2" -o $@

archives/isl-0.16.1.tar.bz2:
	curl -L "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2" -o $@

########################################################################

archives/rpmbuild.tar: rpmbuild/
	tar cvf $@ $<

archives/gcc-7.1.0-33.x86_64.rpm archives/gcc-lib-7.1.0-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/gcc-7.1.0.tar.bz2 archives/isl-0.16.1.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-base /scripts/gcc7.sh $(shell id -u) $(shell id -g)

archives/gcc-6.4.0-33.x86_64.rpm archives/gcc-lib-6.4.0-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/gcc-6.4.0.tar.xz archives/isl-0.16.1.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-base /scripts/gcc6.sh $(shell id -u) $(shell id -g)

archives/freetype-2.8-33.x86_64.rpm archives/freetype-lib-2.8-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/freetype-2.8.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-gcc6 /scripts/freetype.sh $(shell id -u) $(shell id -g)

archives/boost-1_62_0-33.x86_64.rpm archives/boost-lib-1_62_0-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost_1_62_0.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-gcc6 /scripts/boost162.sh $(shell id -u) $(shell id -g)

archives/mapnik-093fcee-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost-1_62_0-33.x86_64.rpm archives/freetype-2.8-33.x86_64.rpm archives/mapbox-geometry-v0.9.2.tar.gz archives/mapbox-variant-v1.1.3.tar.gz archives/mapnik-093fcee6d1ba1fd360718ceade83894aeffc2548.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-gcc6 /scripts/mapnik.sh $(shell id -u) $(shell id -g)

archives/mapnik-python-e5f107d-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost-lib-1_62_0-33.x86_64.rpm archives/mapnik-093fcee-33.x86_64.rpm archives/mapbox-geometry-v0.9.2.tar.gz archives/mapbox-variant-v1.1.3.tar.gz archives/mapnik-python-e5f107d8d459590829d50c976c7a4222d8f4737c.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-gcc6 /scripts/mapnik-python.sh $(shell id -u) $(shell id -g)

########################################################################

archives/gdal-and-friends.tar.gz: scripts/build-gdal.sh \
   archives/gdal-2.1.3.tar.gz \
   archives/geos-3.6.1.tar.bz2 \
   archives/lcms2-2.8.tar.gz \
   archives/libpng-1.6.28.tar.gz \
   archives/proj-4.9.3.tar.gz \
   archives/openjpeg-v2.1.2.tar.gz \
   archives/zlib-1.2.11.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:aws-build-base /scripts/build-gdal.sh $(shell id -u) $(shell id -g)

########################################################################

clean:

cleaner: clean
	rm -f archives/rpmbuild.tar

cleanest: cleaner
	rm -f archives/*.tar.gz archives/*.tar.bz2

mrproper: cleanest
	rm -f archies/*.rpm


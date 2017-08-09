.PHONY: all centos-build-0 centos-build-1 aws-build-0 aws-build-1 base

all: centos-build-0 centos-build-1 aws-build-0 aws-build-1 base

blobs/%: archives/%
	cp -f $< $@

centos-build-0 aws-build-0:
	docker build -t jamesmcclain/jupyter-geopyspark:$@ -f Dockerfile.$@ .

centos-build-1: blobs/gcc-7.1.0-33.x86_64.rpm
	docker build -t jamesmcclain/jupyter-geopyspark:$@ -f Dockerfile.$@ .

aws-build-1: blobs/gdal-and-friends.tar.gz
	docker build -t jamesmcclain/jupyter-geopyspark:$@ -f Dockerfile.$@ .

base: blobs/gdal-and-friends.tar.gz \
   blobs/gcc-lib-7.1.0-33.x86_64.rpm \
   blobs/boost-1_59_0-33.x86_64.rpm \
   blobs/mapnik-v3.0.13-33.x86_64.rpm \
   blobs/python-mapnik-v3.0.13-33.x86_64.rpm
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

archives/boost_1_64_0.tar.bz2:
	curl -L "https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.bz2" -o $@

archives/boost_1_58_0.tar.bz2:
	curl -L "http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2" -o $@

archives/boost_1_59_0.tar.bz2:
	curl -L "http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.bz2" -o $@

archives/gcc-7.1.0.tar.bz2:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-7.1.0/gcc-7.1.0.tar.bz2" -o $@

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
          jamesmcclain/jupyter-geopyspark:centos-build-0 /scripts/gcc7.sh $(shell id -u) $(shell id -g)

archives/boost-1_59_0-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost_1_59_0.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-1 /scripts/boost159.sh $(shell id -u) $(shell id -g)

archives/mapnik-v3.0.13-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost-1_59_0-33.x86_64.rpm archives/mapnik-v3.0.13.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-1 /scripts/mapnik.sh $(shell id -u) $(shell id -g)

archives/python-mapnik-v3.0.13-33.x86_64.rpm: $(shell scripts/not.sh archives/rpmbuild.tar) archives/boost-1_59_0-33.x86_64.rpm archives/mapnik-v3.0.13-33.x86_64.rpm archives/v3.0.13.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          jamesmcclain/jupyter-geopyspark:centos-build-1 /scripts/python-mapnik.sh $(shell id -u) $(shell id -g)

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
          jamesmcclain/jupyter-geopyspark:aws-build-0 /scripts/build-gdal.sh $(shell id -u) $(shell id -g)

########################################################################

clean:

cleaner: clean
	rm -f archives/rpmbuild.tar

cleanest: cleaner
	rm -f archives/*.tar.gz archives/*.tar.bz2

mrproper: cleanest
	rm -f archies/*.rpm


.PHONY: all images

all:

images:

archives/v3.0.13.tar.gz:
	curl -L "https://github.com/mapnik/python-mapnik/archive/v3.0.13.tar.gz" -o $@

archives/mapnik-v3.0.13.tar.bz2:
	curl -L "https://github.com/mapnik/mapnik/releases/download/v3.0.13/mapnik-v3.0.13.tar.bz2" -o $@

archives/boost_1_64_0.tar.bz2:
	curl -L "https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.bz2" -o $@

archives/gcc-7.1.0.tar.bz2:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-7.1.0/gcc-7.1.0.tar.bz2" -o $@

archives/isl-0.16.1.tar.bz2:
	curl -L "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2" -o $@

archives/rpm.tar:
	tar cvf $@ rpm/

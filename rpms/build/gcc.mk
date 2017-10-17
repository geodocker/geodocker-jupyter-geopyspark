rpmbuild/SOURCES/isl-0.16.1.tar.bz2:
	curl -L "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2" -o $@

rpmbuild/SOURCES/gcc-6.4.0.tar.xz:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-6.4.0/gcc-6.4.0.tar.xz" -o $@

rpmbuild/RPMS/x86_64/gcc6-6.4.0-33.x86_64.rpm rpmbuild/RPMS/x86_64/gcc6-lib-6.4.0-33.x86_64.rpm: rpmbuild/SPECS/gcc6.spec rpmbuild/SOURCES/gcc-6.4.0.tar.xz rpmbuild/SOURCES/isl-0.16.1.tar.bz2
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC4IMAGE) /scripts/gcc6.sh $(shell id -u) $(shell id -g)

archives/isl-0.16.1.tar.bz2:
	curl -L "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2" -o $@

archives/gcc-6.4.0.tar.xz:
	curl -L "http://mirrors.concertpass.com/gcc/releases/gcc-6.4.0/gcc-6.4.0.tar.xz" -o $@

archives/gcc6-6.4.0-33.x86_64.rpm archives/gcc6-lib-6.4.0-33.x86_64.rpm: rpmbuild/SPECS/gcc6.spec $(shell scripts/not.sh archives/rpmbuild.tar) $(shell scripts/not.sh archives/gcc-6.4.0.tar.xz) $(shell scripts/not.sh archives/isl-0.16.1.tar.bz2)
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC4IMAGE) /scripts/gcc6.sh $(shell id -u) $(shell id -g)

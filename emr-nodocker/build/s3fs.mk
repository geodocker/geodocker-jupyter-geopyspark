rpmbuild/SOURCES/v1.82.tar.gz:
	curl -L "https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.82.tar.gz" -o $@

rpmbuild/RPMS/x86_64/s3fs-fuse-1.82-33.x86_64.rpm: scripts/s3fs.sh rpmbuild/SPECS/s3fs.spec rpmbuild/SOURCES/v1.82.tar.gz
	docker run -it --rm \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/s3fs.sh $(shell id -u) $(shell id -g)

wheels wheel/http-requirements.txt: archives/ipykernel.zip \
rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/hdf5-1.8.20-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/netcdf-4.5.0-33.x86_64.rpm \
rpmbuild/RPMS/x86_64/gdal231-2.3.1-33.x86_64.rpm \
wheel/requirements.txt
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:ro \
          -v $(shell pwd)/rpmbuild:/tmp/rpmbuild:ro \
          -v $(shell pwd)/wheel:/wheel:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC4IMAGE) /scripts/wheel.sh $(shell id -u) $(shell id -g)
	(cd wheel ; ls *.whl | sed 's,^,http://localhost:28080/,' > http-requirements.txt)

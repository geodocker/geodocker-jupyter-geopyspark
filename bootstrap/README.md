# Introduction #

This directory contains the configuration and build files needed to (re)build the bootstrap images.

# Inventory #

## Images ##

The following images can be built from the materials in this directory:

   - [`aws-build-base`](Dockerfile.aws-build-base) is an image with many build tools included that resembles EMR.
     This image is used to build the [`gdal-and-friends.tar.gz`](Makefile#L123-L134) tarball.
   - [`aws-build-gdal-0`](Dockerfile.aws-build-gdal) is much the same as the above, but it contains the `gdal-and-friends.tar.gz` tarball mentioned above.
     This image is used as the AWS build environment described in the [top-level README.md](../README.md).
   - [`centos-build-base`](Dockerfile.centos-build-base) is much the same as the [`quay.io/geodocker/jupyter-geopyspark`](https://quay.io/repository/geodocker/jupyter-geopyspark) image,
     except that it contains a number of build tools and GIS-related libraries.
     This image is used to build and package [GCC 6.4.0](https://gcc.gnu.org/gcc-6/) which is needed to build the other binaries that are built here.
   - [`centos-build-gcc6`](Dockerfile.centos-build-gcc6) is much the same as the above, but it is used to build most of the binaries in the `base` image are built with it.
   - [`base-0`](Dockerfile.base) is much the same as `quay.io/geodocker/jupyter-geopyspark` but has a number of additional binary dependencies,
     including [Mapnik](https://github.com/mapnik/mapnik), [python-mapnik](https://github.com/mapnik/python-mapnik), and `gdal-and-friends.tar.gz`.
     The final image (produced in the top-level build) is derived from this image.

## Files and Directories ##

   - [`archives`](archives) is an initially-empty directory that is populated with source code, tarballs, and RPMs downloaded or produced during the build process.
   - [`blobs`](blobs) is an initially-empty directory that is populated with archives and RPMS from the `archives` directory.
   - [`rpmbuild`](rpmbuild) is a directory containing configuration files used to produce custom RPMs which are installed in `centos-build-gcc6` and `base-0`.
   - [`scripts`](scripts) is a directory containing scripts used to build the RPMs mentioned above, as well as the `gdal-and-friends.tar.gz` tarball.
   - The various Dockerfiles specify the various images discussed above.
   - [`Makefile`](Makefile) coordinates the build process.

# To Build #

Type `make all` or simply `make` to build everything.

Images can be built individually by typing `make aws-build-base`, `make aws-build-gdal`, `make centos-build-base`, `make centos-build-gcc6`, or `make base` as appropriate.

RPMs can be built individually by typing e.g. [`make archives/gcc6-6.4.0-33.x86_64.rpm`](Makefile#L85-L89).

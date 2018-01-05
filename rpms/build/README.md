# Introduction #

This directory contains the configuration and build files needed to (re)build the base image and the RPMs.

# Inventory #

## Images ##

The following images can be built from the materials in this directory:

   - [`quay.io/geodocker/jupyter-geopyspark:aws-build-gdal-3`](Dockerfile.aws-build-gdal) is an image used to build the `gdal-and-friend.tar.gz` binary blob.  This image is meant to mimic the environment of an EC2 (EMR) instance as closely as possible so as to create a compatible artifact.
   - [`quay.io/geodocker/jupyter-geopyspark:base-3`](Dockerfile.base) is the ancestor images of the image produced in the root of this repository.  It contains mostly slow-rate-of-change binary dependencies.
   - [`quay.io/geodocker/emr-build:gcc4-3`](Dockerfile.gcc4) is used to build RPMs with gcc 4.8.
   - [`quay.io/geodocker/emr-build:gcc6-3`](Dockerfile.gcc6) is used to build RPMs with gcc 6.4.

## Files and Directories ##

   - [`archives`](archives) is an initially-empty directory that is populated with source code, tarballs, and RPMs downloaded or produced during the build process.
   - [`blobs`](blobs) is an initially-empty directory that is populated with archives and RPMS from the `archives` directory.
   - [`rpmbuild`](rpmbuild) is a directory containing configuration files used to produce the RPMs.
   - [`scripts`](scripts) is a directory containing scripts used to build the RPMs mentioned above, as well as the `gdal-and-friends.tar.gz` tarball.
   - [`Makefile`](Makefile) coordinates the build process.
   - [`etc`](etc) contains additional configuration files that are included in the base image.
   - The various Dockerfiles specify the various images discussed above.
   - `*.mk`: these are included in the Makefile.
   - `README.md`: this file.

# RPMs #

## Building ##

From within this directory, type `./build.sh` to build all of the RPMs (this could take a very long time).
Once they are built, type `./publish.sh s3://bucket/prefix/` where `s3://bucket/prefix/` is a "directory" on S3 for which you have write permissions.
The RPMs will be published to `s3://bucket/prefix/abc123/` where `abc123` is the present git SHA.

This will also produce all of the images described above (including the base image).

## Fetching ##

From within this directory, type `./fetch s3://bucket/prefix/abc123/` where `s3://bucket/prefix/` is the path to a "directory" on S3 where RPMs have been previously-published, and `abc123` is the git SHA from which those RPMs were produced.

## Refreshing GeoPySpark ##

With a complete set of RPMs already present, the GeoPySpark RPMs can be refreshed (for example to a newer version) by deleting the old GeoPySpark RPMs, then executing the `rpms` Makefile target.

```bash
rm -f rpmbuild/RPMS/x86_64/geopyspark-*.rpm
make rpms
```

# Introduction #

This repository contains the configuration and build files necessary to produce the [`quay.io/geodocker/jupyter-geopyspark` Docker image](https://quay.io/repository/geodocker/jupyter-geopyspark?tab=tags).
The Docker image allows easy use of [GeoPySpark](https://github.com/locationtech-labs/geopyspark) in a web browser via [Jupyter](https://github.com/jupyter/jupyter/) and [GeoNotebook](https://github.com/opengeoscience/geonotebook) without having to modify or configure the host computer (beyond what is needed to run Docker).

The process of [using a pre-built container](#without-a-clone) is discussed in the next section,
and instructions for [building the image](#building-the-image) and [modifying it](#modifying-the-image-or-image-architecture) are also discussed.

# Using The Image #

One can use the image with or without making a clone of this repository.

## Without A Clone ##

To use the image without (or from outside of) a fork of this repository,
first make sure that you are in possession of the image.
The command
```
docker pull quay.io/geodocker/jupyter-geopyspark
```
will pull the latest version of the image.

The container can then be started by typing
```
docker run -it --rm --name geopyspark \
   -p 8000:8000 \
   quay.io/geodocker/jupyter-geopyspark
```
or perhaps
```
docker run -it --rm --name geopyspark \
   -p 8000:8000 \
   -v $(HOME)/.aws:/home/hadoop/.aws:ro \
   quay.io/geodocker/jupyter-geopyspark
```
if you wish to have your AWS credentials available in the container (e.g. for pulling data from S3).

## From A Clone ##

To use the image from within a clone of this repository,
there are [two useful targets in the Makefile: `run` and `run-editable`](Makefile#L181-L198).
To use the `run` target, type something like
```
TARGET=latest make run
```
or to use the `run` target with some image other than the latest one, something like
```
TARGET=a1b78b9 make run
```
will launch a container using the image `quay.io/geodocker/jupyter-geopyspark:a1b78b9`.

The `run-editable` target also exists, which attempts to map one's local clone of the GeoPySpark into the container so that that code can be edited and iterated on in a fairly convenient fashion.
By default, it is assumed that the GeoPySpark code is present in `../geopyspark/geopyspark`, but than can be changed by passing in an alternate location through the `GEOPYSPARK_DIR` environment variable.
Here
```
TARGET=latest GEOPYSPARK_DIR=/tmp/geopyspark/geopyspark run-editable
```
is an example of that.

Both of those targets also pay attention to the `EXTRA_FLAGS` environment variable which can be used to pass additional flags to docker.

# Building The Image #

To build the image, type `make all` or simply `make`.
The `all` target has two phony dependencies, `stage0` and `stage2`,
whose respective purposes are to build or fetch the stage 0 image (explained below)
and to build the stage 2 (final) image (nomenclature explained below).

# Modifying The Image; or, Image Architecture #

In this section we describe the structure of the repository,
we document how the various pieces interact as part of the build process,
and we detail the internal structure of the image that is produced.

## Repository Structure ##

   - [`archives`](archives) is an initially-empty directory that is populated with source code archives and built artifacts as part of the build process.
   - [`blobs`](blobs) is an initially-empty directory that is populated with hard links to built artifacts in `archives`.
     This directory exists because `archives` is in the [`.dockerignore`](.dockerignore) (which was done to reduce the size of the [build context](https://docs.docker.com/engine/reference/commandline/build/) of the final image).
   - [`config`](config) contains the [GeoNotebook configuration file](config/geonotebook.ini)
     and a [list of python dependencies](config/requirements.txt) that GeoNotebook requires.
   - [`emr`](emr) contains files useful for running the image on Amazon EMR (please see the [README](emr/README.md) in that directory for more information).
   - [`kernels`](kernels) contains Jupyter kernel configuration files.
     The one most likely to be of interest is [the one](geonotebook/kernel.json) that enables GeoNotebook and GeoPySpark, the other two included kernels there are mostly vestigial/ceremonial.
   - [`notebooks`](notebook) contains various sample notebooks.
   - [`scratch`](scratch) is a scratch directory used during the build process.
     The files that are added under this directory during the build can be harmlessly deleted after the build is complete,
     but not doing so will accelerate subsequent builds.
   - [`scripts`](scripts) contains various scripts using for building and installing artifacts.
      - [`netcdf.sh`](scripts/netcdf.sh) builds a jar from a [particular branch](https://github.com/Unidata/thredds/tree/feature/s3+hdfs) of the [Thredds](https://github.com/Unidata/thredds) project that provides support for reading NetCDF files.
      - [`build-native-blob.sh`](scripts/build-native-blob.sh) runs [in the context of the stage 0 container](Makefile#L94-L99).
        Its purpose is to build [GDAL](http://www.gdal.org/) and other binary dependencies *in a way that makes them usable on EMR*.
      - [`build-python-blob1.sh`](build-python-blob1.sh) [runs in the context of the stage 0 container](Makefile#L103-L109),
        its purpose is to acquire most of the python dependencies needed by GeoPySpark and GeoNotebook and package them together into a tarball for later installation.
      - [`build-pytohn-blob2.sh`](build-python-blob2.sh) [runs in the context of the stage 0 container](Makefile#L113-L118),
        its purpose is to package GeoPySpark and [`GeoPySpark-NetCDF`](https://github.com/geotrellis/geopyspark-netcdf) into a tarball for later installation.
      - [`extract-blob.sh`](scripts/extract-blob.sh) runs in the context of the stage 1 container and is used for extracting binary artifacts for use in the stage 2 container build on [Travis](https://travis-ci.org/).
      - [`install-blob1.sh`](scripts/install-blob1.sh) runs [in the context of the stage 2 build](Dockerfile.stage2#L20).
        Its purpose is to install the artifacts created earlier by `build-native-blob.sh` and `build-python-blob1.sh`.
      - [`install-blob2.sh`](scripts/install-blob2.sh) runs [in the context of the stage 2 build](Dockerfile.stage2#L43).
        Its purpose is to install the artifacts created earlier by `build-python-blob2.sh`.
   - [`Dockerfile.stage0`](Dockerfile.stage0) specifies the stage 0 image.  This image provides an environment in which various artifacts are built.
   - [`Dockerfile.stage2`](Dockerfile.stage2) specifies the stage 2 image, the final output of the build process.
   - [`Makefile`](Makefile) coordinates the build process.

## Build Process ##

When the `all` makefile target is invoked, a two- or three-stage build process begins.
In the typical case the build process starts at stage 0, skips stage 1, and completes after stage 2 producing the desired docker image.
In the context of Travis CI, where disk space and memory are more limited, there is a truncated stage 0, there is stage 1 in which those artifacts which could not be built in stage 0 are retrieved, and finally stage 2.

Details are given below.

### Stage 0 ###

The purpose of this stage is to build binary artifacts,
as well as python artifacts that need to be linked against those binary dependencies,
in a context that [resembles EMR](Dockerfile.stage0#L1) (because we want the image to be usable on EMR).

First, the stage 0 image is [pulled or built](Makefile#L77-L78).
In the non-Travis case, that image is then used to build [GDAL and other native dependencies](Makefile#L99).
Once the binary dependencies are in place, a tarball containing python code linked against the binary dependencies [is created](Makefile#L109).
Finally, another python tarball, containing GeoPySpark, [is created](Makefile#L118).
The reason that there are two python tarballs instead of one is simply because contents of the two tarballs change at different rates;
over repeated builds, the first tarball is built less frequently than the second one.

### Stage 1 ###

As stated above, stage 1 only occurs when the image is being built on Travis.
In this stage, the native dependencies are [copied from an earlier version of the stage 2 image](Makefile#L85) for inclusion in stage 2 image that is being built.
This is done because the amount of disk and memory required to build the binary dependencies are simply too large for the Travis environment.

### Stage 2 ###

In stage 2, the artifacts which were created in earlier brought together and installed into the final docker image.

## Adding Binary Dependencies ##

As an example of how to make a meaningful modification to the image,
in this section we will describe the process of adding new binary dependencies to the image.

Currently, all binary dependencies are located in the file [`gdal-and-friends.tar.gz`](Makefile#L16).
If we want to add an additional binary dependency inside of that file,
then it is simply a matter of [downloading or otherwise acquiring the source code](Makefile#L23-L42)
and updating the [build script](scripts/build-native-blob.sh) to build and package the additional code.
If we wish to add a binary dependency outside of the `gdal-and-friends.tar.gz` file, then the process is slightly more involved.

The strategy for adding new binary dependency, hypothetically `libHelloWorld` packaged in a file called `helloworld-and-friends.tar.gz`,
will be to mirror the process for `gdal-and-friends.tar.gz` as closely as possible.
   - As before, it may make sense to augment to [download or otherwise ensure the existence]((Makefile#L23-L42)) of the `libHelloWorld` source code.
   - Next, we want to build and package `libHelloWorld` in the context of the stage 0 image, so that it will be usable on EMR.
     This would probably be done by first creating a script analogous to the one for [GDAL](scripts/build-native-blob.sh) that builds, links, and archives the dependency.
   - That script should [run in the context of the stage 0 container](Makefile#L99) so that the created binaries are compiled and linked in an environment that resembles EMR.
   - The resulting archived binary blob should then be [added to the stage 2](Dockerfile.stage2#L17) so that it can be distributed to the Spark executors.
   - Finally, the [runtime environment](Dockerfile.stage2#L9) and [the kernel](Dockerfile.stage2#L9) should be modified to make use of the new dependency.

The changes to the kernel described in the last bullet-point would probably look something like this
```diff
@@ -9,12 +9,12 @@
         "{connection_file}"
     ],
     "env": {
-        "LD_LIBRARY_PATH": "/home/hadoop/local/gdal/lib",
+        "LD_LIBRARY_PATH": "/home/hadoop/local/gdal/lib:/home/hadoop/local/helloworld/lib",
         "PYSPARK_PYTHON": "/usr/bin/python3.4",
         "SPARK_HOME": "/usr/local/spark-2.1.0-bin-hadoop2.7",
         "PYTHONPATH": "/usr/local/spark-2.1.0-bin-hadoop2.7/python/lib/pyspark.zip:/usr/local/spark-2.1.0-bin-hadoop2.7/python/lib/py4j-0.10.4-src.zip",
         "GEOPYSPARK_JARS_PATH": "/opt/jars",
         "YARN_CONF_DIR": "/yarn",
-        "PYSPARK_SUBMIT_ARGS": "--archives /blobs/gdal-and-friends.tar.gz,/blobs/friends-of-geopyspark.tar.gz,/blobs/geopyspark-sans-friends.tar.gz --conf spark.yarn.appMasterEnv.LD_LIBRARY_PATH=/home/hadoop/local/gdal/lib --conf spark.executorEnv.LD_LIBRARY_PATH=gdal-and-friends.tar.gz/lib:/home/hadoop/local/gdal/lib --conf spark.executorEnv.PYTHONPATH=friends-of-geopyspark.tar.gz/:geopyspark-sans-friends.tar.gz/ --conf hadoop.yarn.timeline-service.enabled=false pyspark-shell"
+        "PYSPARK_SUBMIT_ARGS": "--archives /blobs/helloworld-and-friends.tar.gz,/blobs/gdal-and-friends.tar.gz,/blobs/friends-of-geopyspark.tar.gz,/blobs/geopyspark-sans-friends.tar.gz --conf spark.yarn.appMasterEnv.LD_LIBRARY_PATH=/home/hadoop/local/helloworld/lib:/home/hadoop/local/gdal/lib --conf spark.executorEnv.LD_LIBRARY_PATH=helloworld-and-friends/lib:gdal-and-friends.tar.gz/lib:/home/hadoop/local/helloworld/lib:/home/hadoop/local/gdal/lib --conf spark.executorEnv.PYTHONPATH=friends-of-geopyspark.tar.gz/:geopyspark-sans-friends.tar.gz/ --conf hadoop.yarn.timeline-service.enabled=false pyspark-shell"
     }
 }
```

The process for adding new distributed python dependencies is analogous to the one above,
except that changes to `LD_LIBRARY_PATH` (both in the dockerfile and in the kernel) might not be required,
and additions would need to be made to the `--conf spark.executorEnv.PYTHONPATH` configuration passed in via `PYSPARK_SUBMIT_ARGS` in the kernel.

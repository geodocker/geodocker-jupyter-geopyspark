# Introduction #

This repository contains the configuration and build files necessary to produce the [`quay.io/geodocker/jupyter-geopyspark` Docker image](https://quay.io/repository/geodocker/jupyter-geopyspark?tab=tags).
The Docker image allows easy use of [GeoPySpark](https://github.com/locationtech-labs/geopyspark) in a web browser via [Jupyter](https://github.com/jupyter/jupyter/) and [GeoNotebook](https://github.com/opengeoscience/geonotebook) without having to modify or configure the host computer (beyond what is needed to run Docker).

The process of [using a pre-built container](#without-a-clone) is discussed in the next section,
and instructions for [building the image](#building-the-image) and [modifying it](#modifying-the-image-or-image-architecture) are also discussed.

# Using The Image #

One can use the image with or without making a clone of this repository.

## Without A Clone ##

To use the image without (or from outside of) a fork of this repository, first make sure that you are in possession of the image.
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

To use the image from within a clone of this repository, there are [two useful targets in the Makefile: `run` and `run-editable`](Makefile#L181-L198).
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

# Modifying The Image; or, Image Architecture #

## Repository Structure ##

## Build Process ##

## Image Structure ##

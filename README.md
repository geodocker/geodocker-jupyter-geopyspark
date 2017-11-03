# Introduction #

This repository contains the configuration and build files necessary to produce the [`quay.io/geodocker/jupyter-geopyspark` Docker image](https://quay.io/repository/geodocker/jupyter-geopyspark?tab=tags).
The Docker image allows easy use of [GeoPySpark](https://github.com/locationtech-labs/geopyspark) in a web browser via [Jupyter](https://github.com/jupyter/jupyter/) and [GeoNotebook](https://github.com/opengeoscience/geonotebook) without having to modify or configure the host computer (beyond what is needed to run Docker).

The process of [using a pre-built container](#without-a-clone) is discussed in the next section,
and instructions for [building the image](#building-the-image) and [modifying it](#modifying-the-image-or-image-architecture) are also discussed.

# Using The Image #

One can use the image with or without making a clone of this repository.

## Without A Clone ##

To use the image without (or from outside of) a clone of this repository,
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
   -v $HOME/.aws:/home/hadoop/.aws:ro \
   quay.io/geodocker/jupyter-geopyspark
```
if you wish to have your AWS credentials available in the container (e.g. for pulling data from S3).

## From A Clone ##

To use the image from within a clone of this repository,
there are [two useful targets in the Makefile: `run` and `run-editable`](Makefile#L149-L166).
To use the `run` target, type something like
```
TAG=latest make run
```
or to use the `run` target with some image other than the latest one, something like
```
TAG=a1b78b9 make run
```
will launch a container using the image `quay.io/geodocker/jupyter-geopyspark:a1b78b9`.

The `run-editable` target also exists, which attempts to map one's local clone of the GeoPySpark into the container so that that code can be edited and iterated on in a fairly convenient fashion.
By default, it is assumed that the GeoPySpark code is present in `../geopyspark/geopyspark`, but that assumption can be changed by passing in an alternate location through the `GEOPYSPARK_DIR` environment variable.
Here
```
TAG=latest GEOPYSPARK_DIR=/tmp/geopyspark/geopyspark run-editable
```
is an example of that.

Both of those targets also pay attention to the `EXTRA_FLAGS` environment variable which can be used to pass additional flags to docker.

# Building The Image #

To build the image, type `make all`, `make image`, or simply `make`.

Type
```
make run
```
to run the newly-built image.
The `TAG` environment variable is not set, so by default the `run` target will use the tag of the new image.

# Modifying The Image; or, Image Architecture #

In this section we describe the structure of the repository
and document how the various pieces interact as part of the build process.

## Repository Structure ##

   - [`archives`](archives) is an initially-empty directory that is populated with source code and built artifacts as part of the build process.
   - [`blobs`](blobs) is an initially-empty directory that is populated with built artifacts from the `archives` directory.
     This directory exists because `archives` is listed in the [`.dockerignore`](.dockerignore) file
     (which was done to reduce the size of the [build context](https://docs.docker.com/engine/reference/commandline/build/) of the final image).
     Please see the [README](bootstrap/README.md) in that directory for more information.
   - [`config`](config) contains the [GeoNotebook configuration file](config/geonotebook.ini)
     and a [list of python dependencies](config/requirements.txt) that GeoNotebook requires.
   - [`emr-docker`](emr-docker) contains files useful for running the image on Amazon EMR (please see the [README](emr-docker/README.md) in that directory for more information).
   - [`terraform-docker`](terraform-docker) contains file useful for running the image on Amazon EMR using Terraform.  Its remit is similar to that of the directory mentioned in the previous bullet-point, but it uses Terraform instead of shell scripts.
   - [`kernels`](kernels) contains Jupyter kernel configuration files.
     The one most likely to be of interest is [the one](geonotebook/kernel.json) that enables GeoNotebook and GeoPySpark, the other two kernels are mostly vestigial/ceremonial.
   - [`notebooks`](notebook) contains various sample notebooks.
   - [`scratch`](scratch) is a scratch directory used during the build process.
     The files that are added under this directory during the build can be harmlessly deleted after the build is complete,
     but not doing so will accelerate subsequent builds.
   - [`scripts`](scripts) contains various scripts using for building and installing artifacts.
      - [`netcdf.sh`](scripts/netcdf.sh) builds a jar from a [particular branch](https://github.com/Unidata/thredds/tree/feature/s3+hdfs) of the [Thredds](https://github.com/Unidata/thredds) project that provides support for reading NetCDF files.
      - [`build-python-blob1.sh`](build-python-blob1.sh) [runs in the context of the AWS build container](Makefile#L62-L70),
        its purpose is to acquire most of the python dependencies needed by GeoPySpark and GeoNotebook and package them together into a tarball for later installation.
      - [`build-pytohn-blob2.sh`](build-python-blob2.sh) [runs in the context of the AWS build container](Makefile#L72-L80),
        its purpose is to package GeoPySpark and [`GeoPySpark-NetCDF`](https://github.com/geotrellis/geopyspark-netcdf) into a tarball for later installation.
      - [`install-blob1.sh`](scripts/install-blob1.sh) runs [in the context of the final image build](Dockerfile#L17).
        Its purpose is to install the artifacts created earlier by `build-python-blob1.sh`.
      - [`install-blob2.sh`](scripts/install-blob2.sh) runs [in the context of the final image build](Dockerfile#L40).
        Its purpose is to install the artifacts created earlier by `build-python-blob2.sh`.
   - [`Dockerfile`](Dockerfile) specifies the final image, the output of the build process.
   - [`Makefile`](Makefile) coordinates the build process.
   - [`README.md`](README.md) this file.

## Build Process ##

The build process can be divided into three stages: the bootstrap image creation phase, the EMR-compatible artifact creation stage, and the final image build stage.

When the `all` makefile target is invoked, the last two stages of the three-stage build process are done.

### Stage 0: Build Bootstrap Images ###

The first of the three stages is done using the contents of the [`rpms/build`](rpms/build) directory.
Its results have already been pushed to the `quay.io/geodocker` docker repository, so unless the reader wishes to modify the bootstrap images, this stage can be considered complete.
To rebuild the boostrap images, the reader should navigate into the `rpms/build` directory and run the `./build.sh` script.

### Stage 1: EMR-Compatible Artifacts  ###

The purpose of this stage is to build python artifacts that need to be linked against those binary dependencies which have been built
in a context that resembles EMR (because we want the image to be usable on EMR).

First, a tarball containing python code linked against the binary dependencies mentioned above [is created](Makefile#L62-L70).
Then, another python tarball containing GeoPySpark [is created](Makefile#L72-L80).
The reason that there are two python tarballs instead of one is simply because contents of the two tarballs change at different rates;
over repeated builds, the first tarball is built less frequently than the second one.

### Stage 2: Build Final Image ###

In the third of the three stages, the artifacts which were created earlier are brought together and installed into the final docker image.

## Adding Binary Dependencies ##

As an example of how to make a meaningful modification to the image,
in this section we will describe the process of adding new binary dependencies to the image.

Currently, all binary dependencies are located in the file [`gdal-and-friends.tar.gz`](bootstrap/Makefile#L123-L134) which comes in via the [`quay.io/geodocker/jupyter-geopyspark:base-2`](rpms/build/Dockerfile.base) image on which the final image is based.
If we want to add an additional binary dependency inside of that file,
then we only need to [download or otherwise acquire the source code](rpms/build/Makefile#L3-L17)
and update the [build script](rpms/build/scripts/build-gdal.sh) to build and package the additional code.
If we wish to add a binary dependency outside of the `gdal-and-friends.tar.gz` file, then the process is slightly more involved,
but potentially faster because it is not necessary to rebuild bootstrap images.

The strategy for adding new binary dependency, hypothetically `libHelloWorld` packaged in a file called `helloworld-and-friends.tar.gz`,
will be to mirror the process for `gdal-and-friends.tar.gz` to the extent that we can.
The difference is that this time we will add the binary to the final image rather than to a bootstrap image.
   - First, augment to the [`Makefile`](Makefile) to download or otherwise ensure the existence of the `libHelloWorld` source code.
   - Next, we want to build and package `libHelloWorld` in the context of the AWS build image, so that it will be usable on EMR.
     This would probably be done by first creating a script analogous to [the one for GDAL](rpms/build/scripts/build-gdal.sh) that builds, links, and archives the dependency.
   - That script should run in the context of the AWS build container so that the created binaries are compiled and linked in an environment that resembles EMR.
   - The resulting archived binary blob should then be added to the final image so that it can be distributed to the Spark executors.
     That should probably be done by adding a the `COPY` command to the Dockerfile to copy the new blob to the `/blobs` directory of the image.
   - Finally, the image environment and the kernel should both be modified to make use of the new dependency.
     The former will probably involve the addition of an `ENV` command to the Dockerfile to augment the `LD_LIBRARY_PATH` environment variable to be able to find any new shared libraries;
     The latter is described below.

The changes to the kernel described in the last bullet-point would probably look something like this
```diff
@@ -14,6 +14,6 @@
         "PYTHONPATH": "/usr/local/spark-2.1.0-bin-hadoop2.7/python/lib/pyspark.zip:/usr/local/spark-2.1.0-bin-hadoop2.7/python/lib/py4j-0.10.4-src.zip",
         "GEOPYSPARK_JARS_PATH": "/opt/jars",
         "YARN_CONF_DIR": "/etc/hadoop/conf",
-        "PYSPARK_SUBMIT_ARGS": "--archives /blobs/gdal-and-friends.tar.gz,/blobs/friends-of-geopyspark.tar.gz,/blobs/geopyspark-sans-friends.tar.gz --conf spark.executorEnv.LD_LIBRARY_PATH=gdal-and-friends.tar.gz/lib --conf spark.executorEnv.PYTHONPATH=friends-of-geopyspark.tar.gz/:geopyspark-sans-friends.tar.gz/ --conf hadoop.yarn.timeline-service.enabled=false pyspark-shell"
+        "PYSPARK_SUBMIT_ARGS": "--archives /blobs/helloworld-and-friends.tar.gz,/blobs/gdal-and-friends.tar.gz,/blobs/friends-of-geopyspark.tar.gz,/blobs/geopyspark-sans-friends.tar.gz --conf spark.executorEnv.LD_LIBRARY_PATH=helloworld-and-friends.tar.gz/lib:gdal-and-friends.tar.gz/lib --conf spark.executorEnv.PYTHONPATH=friends-of-geopyspark.tar.gz/:geopyspark-sans-friends.tar.gz/ --conf hadoop.yarn.timeline-service.enabled=false pyspark-shell"
     }
 }
```

(The changes represented by the diff above have not been tested.)

The process for adding new distributed python dependencies is analogous to the one above,
except that changes to `LD_LIBRARY_PATH` variable on the executors might not be required,
and additions most-probably will need to be made to the `--conf spark.executorEnv.PYTHONPATH` configuration passed in via `PYSPARK_SUBMIT_ARGS` in the kernel.

# RPM-based Deployment #

## Build RPMs ##

To build the RPMs, navigate into the [`rpms/build`](rpms/build/) directory and type `./build.sh`.

## Terraform And AWS ##

To use the RPM-based deployment, navigate into the [`terraform-nodocker`](terraform-nodocker/) directory.
The configuration in that directory require [Terraform](https://www.terraform.io/) version 0.10.6 or greater.
If you want to use Google OAuth, GitHub OAuth, or some supported generic type of OAuth, then type
```bash
terraform init
terraform apply
```
and respond appropriatly to the prompts.

Doing that will upload (or sync) the RPMs to the S3 location that you specify, and will also upload the [`terraform-nodocker/bootstrap.sh`](terraform-nodocker/bootstrap.sh) bootstrap script.

If you do not wish to use OAuth, then [some modifications to the bootstrap script](terraform-nodocker/bootstrap.sh#L84-L93) will be required.

# OAuth #

## With The Docker Image ##

In to use OAuth for login, two things are necessary:
It is necessary to [set three environment](https://github.com/jupyterhub/oauthenticator/blame/f5e39b1ece62b8d075832054ed3213cc04f85030/README.md#L74-L78) variables inside of the container before the JupyterHub process is launched, and
it is necessary to use a `jupyterhub_config.py` file that enables the desired OAuth setup.

### Environment Variables ###

The three environment variables that must be set are `OAUTH_CALLBACK_URL`, `OAUTH_CLIENT_ID`, and `OAUTH_CLIENT_SECRET`.
The first of those three variables should be set to `http://localhost:8000/hub/oauth_callback` for local testing and something like `http://$(hostname -f):8000/hub/oauth_callback` for deployment.
The second and third are dependent on the OAuth provider.

### `jupyterhub_config.py` ###

There three such files already included in the image:
One for [Google](config/jupyterhub_config_google.py) and related services,
one for [GitHub](config/jupyterhub_config_github.py),
and a [generic](config/jupyterhub_config_generic.py) one.
There is some variability in precise details of how OAuth providers work (e.g. some require variables to be passed in the URL of a POST request, whereas others require variables to passed in the body of a POST request).
For that reason, the generic configuration should be considered a starting point rather than something that is guranteed to work in its unmodified state.

There are only two user accounts in the image: `root` and `hadoop`.
All three of the configurations discussed above map all valid OAuth users to the `hadoop` account.
That is done because -- without additional configuration -- Spark jobs on EMR must come from a user named "`hadoop`".
(The users inside of the container are separate and distinct from those on the host instance,
but the username is evidently part of a Spark job submission, so it must match that of the user that EMR is expecting submissions from.)

### Using ###

To use OAuth, launch a container with the three variables supplied and with the appropriate `jupyterhub_config.py` used.

```bash
docker run -it --rm --name geopyspark \
   -p 8000:8000 \
   -e OAUTH_CALLBACK_URL=http://localhost:8000/hub/oauth_callback \
   -e OAUTH_CLIENT_ID=xyz \
   -e OAUTH_CLIENT_SECRET=abc \
   quay.io/geodocker/jupyter-geopyspark:latest \
      jupyterhub \
      -f /etc/jupterhub/jupyterhub_config_github.py \
      --no-ssl --Spawner.notebook_dir=/home/hadoop/notebooks
```

## With The RPM-based Deployment ##

This was discussed [earlier](#terraform-and-aws).

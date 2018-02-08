FROM quay.io/geodocker/jupyter-geopyspark:base-6

ARG VERSION
ARG GEONOTEBOOKSHA
ARG GEOPYSPARKSHA

ENV PYSPARK_PYTHON=python3.4
ENV PYSPARK_DRIVER_PYTHON=python3.4

# Install KTile, GeoNotebook
RUN mkdir /home/hadoop/notebooks && \
    pip3 install --user pytest \
        "https://github.com/OpenGeoscience/ktile/archive/0370c334467dc2928a04e201d0c9c0a07f28b181.zip" \
        "https://github.com/geotrellis/geonotebook/archive/$GEONOTEBOOKSHA.zip" && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter serverextension enable --py geonotebook && \
    jupyter nbextension enable --py geonotebook

COPY config/geonotebook.ini /home/hadoop/.local/etc/geonotebook.ini
COPY kernels/geonotebook/kernel.json /home/hadoop/.local/share/jupyter/kernels/geonotebook3/kernel.json

# Install GeoPySpark
RUN pip3 install --user protobuf==3.1.0 "https://github.com/locationtech-labs/geopyspark/archive/$GEOPYSPARKSHA.zip"

# Install Jars
ADD https://s3.amazonaws.com/geopyspark-dependency-jars/geotrellis-backend-assembly-0.3.1.jar /opt/jars/

USER root
RUN chmod ugo+r /opt/jars/*
USER hadoop

WORKDIR /tmp
CMD ["jupyterhub", "--no-ssl", "--Spawner.notebook_dir=/home/hadoop/notebooks"]

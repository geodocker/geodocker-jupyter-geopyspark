FROM quay.io/geodocker/jupyter-geopyspark:base-5

ARG VERSION
ARG GEONOTEBOOKSHA
ARG PYTHONBLOB1
ARG PYTHONBLOB2

ENV PYSPARK_PYTHON=python3.4
ENV PYSPARK_DRIVER_PYTHON=python3.4

RUN mkdir /home/hadoop/notebooks && \
    pip3 install --user pytest \
        "https://github.com/OpenGeoscience/ktile/archive/0370c334467dc2928a04e201d0c9c0a07f28b181.zip" \
        "https://github.com/geotrellis/geonotebook/archive/$GEONOTEBOOKSHA.zip" && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter serverextension enable --py geonotebook && \
    jupyter nbextension enable --py geonotebook

COPY config/geonotebook.ini /home/hadoop/.local/etc/geonotebook.ini
COPY kernels/geonotebook/kernel.json /home/hadoop/.local/share/jupyter/kernels/geonotebook3/kernel.json
# COPY kernels/local/kernel.json /usr/local/share/jupyter/kernels/pyspark/
# COPY kernels/yarn/kernel.json /usr/local/share/jupyter/kernels/pysparkyarn/

# Install GeoPySpark
COPY blobs/$PYTHONBLOB2 /blobs/
COPY scripts/install-blob2.sh /scripts/
RUN /scripts/install-blob2.sh $PYTHONBLOB2

# YARN
COPY config/core-site.xml /etc/hadoop/conf/
COPY config/yarn-site.xml /etc/hadoop/conf/
COPY config/jupyterhub_config_*.py /etc/jupterhub/
COPY scripts/jupyterhub.sh /scripts/

# Install Jars
# ADD https://s3.amazonaws.com/geopyspark-dependency-jars/geotrellis-backend-assembly-$VERSION-deps.jar /opt/jars/
# ADD https://dl.bintray.com/azavea/maven/org/locationtech/geotrellis/geotrellis-backend_2.11/$VERSION/geotrellis-backend_2.11-$VERSION.jar /opt/jars/
ADD https://s3.amazonaws.com/geopyspark-dependency-jars/geotrellis-backend-assembly-0.3.1.jar /opt/jars/

USER root
RUN chown hadoop:hadoop -R /etc/hadoop/conf && chmod ugo+r /opt/jars/*
USER hadoop

WORKDIR /tmp
CMD ["/scripts/jupyterhub.sh"]

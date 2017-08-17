FROM jamesmcclain/jupyter-geopyspark:base

ARG VERSION
ARG GEONOTEBOOKSHA
ARG PYTHONBLOB1
ARG PYTHONBLOB2

ENV LD_LIBRARY_PATH /home/hadoop/local/gdal/lib
ENV PYSPARK_PYTHON=python3.4
ENV PYSPARK_DRIVER_PYTHON=python3.4

# Install stage1 scripts
COPY scripts/extract-blob.sh /scripts/

# Install Python dependencies
COPY blobs/$PYTHONBLOB1 /blobs/
COPY scripts/install-blob1.sh /scripts/
RUN pip3 install --user pytest && /scripts/install-blob1.sh $PYTHONBLOB1

# Install remaining GeoNotebook dependencies
COPY config/requirements.txt /tmp/requirements.txt
RUN pip3 install --user -r /tmp/requirements.txt && \
    pip3 install --user "https://github.com/OpenGeoscience/ktile/archive/0370c334467dc2928a04e201d0c9c0a07f28b181.zip"

# Install GeoNotebook
COPY blobs/geonotebook-$GEONOTEBOOKSHA.zip /tmp
RUN mkdir /home/hadoop/notebooks && \
    (pushd /tmp ; unzip -q geonotebook-$GEONOTEBOOKSHA.zip ; popd) && \
    (pushd /tmp/geonotebook-$GEONOTEBOOKSHA ; pip3 install --user . ; popd) && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter serverextension enable --py geonotebook && \
    jupyter nbextension enable --py geonotebook
COPY config/geonotebook.ini /home/hadoop/.local/etc/geonotebook.ini
COPY kernels/geonotebook/kernel.json /home/hadoop/.local/share/jupyter/kernels/geonotebook3/kernel.json
COPY kernels/local/kernel.json /usr/local/share/jupyter/kernels/pyspark/
COPY kernels/yarn/kernel.json /usr/local/share/jupyter/kernels/pysparkyarn/

# Install GeoPySpark
COPY blobs/$PYTHONBLOB2 /blobs/
COPY scripts/install-blob2.sh /scripts/
RUN /scripts/install-blob2.sh $PYTHONBLOB2

# Install Jars
COPY blobs/geotrellis-backend-assembly-$VERSION.jar /opt/jars/
COPY blobs/gddp-assembly-$VERSION.jar /opt/jars/

WORKDIR /tmp
CMD ["jupyterhub", "--no-ssl", "--Spawner.notebook_dir=/home/hadoop/notebooks"]

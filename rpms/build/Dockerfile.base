FROM amazonlinux:2016.09.1.20161221
MAINTAINER James McClain <james.mcclain@gmail.com>

RUN yum makecache fast

# Java
RUN yum update -y
RUN yum install -y java-1.8.0-openjdk

# Spark
ENV SPARK_HOME /usr/local/spark-2.1.0-bin-hadoop2.7
ADD blobs/spark-2.1.0-bin-hadoop2.7.tgz /usr/local
RUN ln -s /usr/local/spark-2.1.0-bin-hadoop2.7 /usr/local/spark

# kit, caboodle
RUN yum install -y \
    http://localhost:18080/hdf5-1.8.20-33.x86_64.rpm \
    http://localhost:18080/netcdf-4.5.0-33.x86_64.rpm \
    http://localhost:18080/openjpeg230-2.3.0-33.x86_64.rpm \
    http://localhost:18080/gdal231-2.3.1-33.x86_64.rpm \
    http://localhost:18080/nodejs-8.5.0-13.x86_64.rpm \
    http://localhost:18080/proj493-lib-4.9.3-33.x86_64.rpm \
    http://localhost:18080/configurable-http-proxy-0.0.0-13.x86_64.rpm

RUN echo /usr/local/lib >> /etc/ld.so.conf.d/local.conf && \
    echo /usr/local/lib64 >> /etc/ld.so.conf.d/local.conf && \
    ldconfig

# Create user
RUN yum install -y shadow-utils && \
    useradd hadoop -m && usermod -a -G root hadoop && (echo 'hadoop:hadoop' | chpasswd)

# Misc
RUN yum install -y unzip python34 pam
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.4
RUN ln -s /usr/local/share/jupyter /usr/share/jupyter
COPY etc/pam.d/login /etc/pam.d/login

RUN pip3.4 install -r http://localhost:28080/http-requirements.txt

USER hadoop

FROM amazonlinux:2016.09.1.20161221
MAINTAINER James McClain <james.mcclain@gmail.com>

RUN yum -y groupinstall "Development Tools" || echo
RUN yum -y install python34-devel cmake less nano && yum clean all
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.4
RUN yum update -y
RUN yum install -y java-1.8.0-openjdk-devel
RUN yum clean all -y && yum update -y && \
    yum install -y \
      bzip2-devel \
      cairo-devel \
      libjpeg-turbo-devel \
      libpng-devel \
      libtiff-devel \
      make \
      pkgconfig \
      rpm-build \
      which \
      zlib-devel
RUN ln -s /usr/include/python3.4m /usr/include/python3.4

RUN yum makecache fast
ENV JAVA_HOME=/etc/alternatives/jre

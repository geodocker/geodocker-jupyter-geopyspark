# Container for publishing GeoDocker RPMs to RPM repo on hosted S3
FROM centos:7

RUN yum update -y && \
yum install -y awscli createrepo && \
yum clean all

ENV REGION "us-east-1"
ENV AWS_PROFILE "geotrellis"

COPY scripts/publish-rpm.sh /publish-rpm.sh
COPY scripts/promote-rpm.sh /promote-rpm.sh

VOLUME /rpmbuild /root/.aws

CMD ["/publish-rpm.sh", "-s", "/rpmbuild", "-t", "geotrellis-yum"]
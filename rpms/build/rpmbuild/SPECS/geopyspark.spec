%define _topdir   /tmp/rpmbuild
%define name      geopyspark
%define release   13
%define version   0.3.0

BuildRoot: %{buildroot}
Summary:   GeoPySpark
License:   Apache 2.0
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    geopyspark.tar
Prefix:    /
Group:     Geography
AutoReq:   no

%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%description
GeoPySpark 0.3.0

%prep
%setup -q -n geopyspark

%build
echo

%install
find /usr/local/lib /usr/local/lib64 | sort > before.txt
pip3 install -r requirements.txt
find /usr/local/lib /usr/local/lib64 | sort > after.txt
tar cvf /tmp/packages.tar $(diff before.txt after.txt | grep '^>' | cut -f2 '-d ')
cd %{buildroot}
tar axvf /tmp/packages.tar
mkdir -p %{buildroot}/opt/jars
cd %{buildroot}/opt/jars
curl -L -O https://dl.bintray.com/azavea/maven/org/locationtech/geotrellis/geotrellis-backend_2.11/%{version}/geotrellis-backend_2.11-%{version}.jar
curl -L -O https://dl.bintray.com/azavea/maven/org/locationtech/geotrellis/geopyspark-gddp_2.11/%{version}/geopyspark-gddp_2.11-%{version}.jar
curl -L -O https://s3.amazonaws.com/geopyspark-dependency-jars/geotrellis-backend-assembly-%{version}-deps.jar
curl -L -O https://s3.amazonaws.com/geopyspark-dependency-jars/netcdfAll-5.0.0-SNAPSHOT.jar

%package worker
Summary: GeoPySpark
Group:   Geography
AutoReq: no
%description worker
Just the Python parts

%files
%defattr(-,root,root)
/usr/local/lib/*
/usr/local/lib64/*
/opt/jars/*

%files worker
%defattr(-,root,root)
/usr/local/lib/*
/usr/local/lib64/*

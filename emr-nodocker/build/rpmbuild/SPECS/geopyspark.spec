%define _topdir   /tmp/rpmbuild
%define name      geopyspark
%define release   13
%define version   0.2.2

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
GeoPySpark 0.2.2

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
cp /archives/gddp-assembly-%{version}.jar /archives/geotrellis-backend-assembly-%{version}.jar %{buildroot}/opt/jars

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

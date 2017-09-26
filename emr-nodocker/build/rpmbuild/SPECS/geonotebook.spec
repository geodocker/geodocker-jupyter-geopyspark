%define _topdir   /tmp/rpmbuild
%define name      geonotebook
%define release   13
%define version   0.0.0

BuildRoot: %{buildroot}
Summary:   GeoNotebook
License:   Apache 2.0
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    geonotebook.tar
Prefix:    /
Group:     Geography
AutoReq:   no

%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%description
GeoNotebook 0.0.0

%prep
%setup -q -n geonotebook

%build
echo

%install
find /usr/local /usr/share | sort > before.txt
pip3 install -r requirements.txt
jupyter nbextension enable --py widgetsnbextension --system
jupyter serverextension enable --py geonotebook --system
jupyter nbextension enable --py geonotebook --system
find /usr/local /usr/share | sort > after.txt
tar cvf /tmp/packages.tar $(diff before.txt after.txt | grep '^>' | cut -f2 '-d ')

cd %{buildroot}
tar axvf /tmp/packages.tar

%files
%defattr(-,root,root)
/usr/local/*
/usr/share/*

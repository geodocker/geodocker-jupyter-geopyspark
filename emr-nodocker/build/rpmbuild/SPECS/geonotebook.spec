%define _topdir   /tmp/rpmbuild
%define name      geonotebook
%define release   13
%define version   0.0

BuildRoot: %{buildroot}
Summary:   GeoNotebook
License:   Apache 2.0
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    geonotebook.tar
Prefix:    /usr/local/
Group:     Geography

%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%description
GeoNotebook 0.0

%prep
%setup -q -n geonotebook

%build
echo

%install
find /usr/local | grep 'site-packages/[^/]\+$' | sort > before.txt
pip3 install -r requirements.txt
find /usr/local | grep 'site-packages/[^/]\+$' | sort > after.txt
tar cvf /tmp/packages.tar $(diff before.txt after.txt | grep '^>' | cut -f2 '-d ')
cd %{buildroot}
tar axvf /tmp/packages.tar

%files
%defattr(-,root,root)
/usr/local/lib/*
/usr/local/lib64/*

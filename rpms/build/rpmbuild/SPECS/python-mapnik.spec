%define _topdir   /tmp/rpmbuild
%define name      python-mapnik
%define release   33
%define version   e5f107d

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   Python bindings for Mapnik
License:   LGPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip
Prefix:    /usr/local/lib/python3.4/site-package
Group:     Azavea

%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%description
Mapnik Python e5f107d

%prep
%setup -q -n python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c

%build
echo

%install
pip3 install --target %{buildroot}/usr/local/lib/python3.4/site-packages .

%files
%defattr(-,root,root)
/usr/local/lib/python3.4/site-packages/*

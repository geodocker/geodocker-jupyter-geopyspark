%define _topdir   /tmp/rpmbuild
%define name      python-mapnik
%define release   33
%define version   v3.0.13

BuildRoot: %{buildroot}
Summary:   Python Mapnik
License:   LGPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{version}.tar.gz
Prefix:    /usr/lib/python3.4/site-package
Group:     Geography

%description
Python Mapnik 3.0.13

%prep
%setup -q -n python-mapnik-3.0.13

%build
echo

%install
pip3 install --target %{buildroot}/usr/lib/python3.4/site-packages .

%files
%defattr(-,root,root)
/usr/lib/python3.4/site-packages/*

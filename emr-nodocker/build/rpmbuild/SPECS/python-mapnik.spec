%define _topdir   /tmp/rpmbuild
%define name      python-mapnik
%define release   33
%define version   e5f107d

BuildRoot: %{buildroot}
Summary:   Python bindings for Mapnik
License:   LGPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c.zip
Prefix:    /usr/lib/python3.4/site-package
Group:     Geography

%description
Mapnik Python e5f107d

%prep
%setup -q -n python-mapnik-e5f107d8d459590829d50c976c7a4222d8f4737c

%build
echo

%install
pip3 install --target %{buildroot}/usr/lib/python3.4/site-packages .

%files
%defattr(-,root,root)
/usr/lib/python3.4/site-packages/*

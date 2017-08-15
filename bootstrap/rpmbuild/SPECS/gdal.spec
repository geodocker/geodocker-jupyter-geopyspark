%define _topdir   /tmp/rpmbuild
%define name      gdal
%define release   33
%define version   2.1.3

BuildRoot: %{buildroot}
Summary:   GDAL
License:   X/MIT
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}-%{version}.tar.gz
Prefix:    /usr/local
Group:     Geography

%description
GDAL

%prep
%setup -q

%build
./configure --prefix=/usr/local --with-static-proj4=/usr/local
make -k -j 33 || make

%install
make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
/usr/local/*

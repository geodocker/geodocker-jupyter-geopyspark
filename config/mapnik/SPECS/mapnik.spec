%define _topdir   /tmp/mapnik
%define name      mapnik
%define release   13
%define version   v3.0.15

BuildRoot: %{buildroot}
Summary:   Mapnik
License:   LGPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}-%{version}.tar.bz2
Prefix:    /usr
Group:     Geography

%description
Mapnik 3.0.15

%prep
%setup -q

%build
python scons/scons.py configure DESTDIR=%{buildroot} PREFIX=/usr
python scons/scons.py -j 33

%install
python scons/scons.py install

%files
%defattr(-,root,root)
/usr/bin/mapnik*
/usr/bin/shapeindex
/usr/include/mapnik/*
/usr/lib/libmapnik*
/usr/lib/mapnik/*

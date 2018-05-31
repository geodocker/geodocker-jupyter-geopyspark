%define _topdir   /tmp/rpmbuild
%define name      gdal213
%define release   33
%define version   2.1.3

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   GDAL
License:   X/MIT
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    gdal-%{version}.tar.gz
Prefix:    /usr/local
Group:     Azavea
Requires:  libpng
Requires:  libcurl
Requires:  libgeos
Requires:  hdf5
Requires:  netcdf
BuildRequires: geos-devel
BuildRequires: lcms2-devel
BuildRequires: libcurl-devel
BuildRequires: libpng-devel
BuildRequires: openjpeg-devel
BuildRequires: zlib-devel
BuildRequires: hdf5
BuildRequires: netcdf

%description
GDAL

%prep
%setup -q -n gdal-2.1.3

%build
LDFLAGS='-L/usr/local/lib -L/usr/local/lib64' CC='gcc48' ./configure --prefix=/usr/local
nice -n 19 make -k -j$(grep -c ^processor /proc/cpuinfo) || make

%install
nice -n 19 make DESTDIR=%{buildroot} install

%package lib
Group: Geography
Summary: GDAL
%description lib
The libraries

%files lib
%defattr(-,root,root)
/usr/local/lib/*

%files
%defattr(-,root,root)
/usr/local/*

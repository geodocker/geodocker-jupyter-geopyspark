%define _topdir   /tmp/rpmbuild
%define name      gdal231
%define release   33
%define version   2.3.1

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
BuildRequires: openjpeg230
BuildRequires: zlib-devel
BuildRequires: hdf5
BuildRequires: netcdf

%description
GDAL

%prep
%setup -q -n gdal-2.3.1

%build
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig LDFLAGS='-L/usr/local/lib -L/usr/local/lib64' CC='gcc48' ./configure --prefix=/usr/local --with-java --with-curl --with-openjpeg
nice -n 19 make -k -j$(grep -c ^processor /proc/cpuinfo) || make
make -C swig/java

%install
nice -n 19 make DESTDIR=%{buildroot} install
cp -L swig/java/.libs/libgdalalljni* %{buildroot}/usr/local/lib/
cp swig/java/gdal.jar %{buildroot}/usr/local/share/

%package lib
Group: Geography
Summary: GDAL
%description lib
The libraries

%files lib
%defattr(-,root,root)
/usr/local/lib
/usr/local/share/gdal.jar

%files
%defattr(-,root,root)
/usr/local/*
/usr/local/share/gdal.jar

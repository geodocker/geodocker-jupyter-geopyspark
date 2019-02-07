%define _topdir   /tmp/rpmbuild
%define name      openjpeg230
%define release   33
%define version   2.3.0

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   OpenJPEG
License:   X/MIT
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    openjpeg-%{version}.tar.gz
Prefix:    /usr/local
Group:     Azavea
Requires:  libpng
Requires:  libcurl
Requires:  libgeos
Requires:  hdf5
Requires:  netcdf
BuildRequires: cmake
BuildRequires: lcms2-devel

%description
OpenJPEG

%prep
%setup -q -n openjpeg-2.3.0

%build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
make

%install
cd build && make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
/usr/local/lib/openjpeg-2.3/*
/usr/local/lib/pkgconfig/libopenjp2.pc
/usr/local/lib/libopenjp2*
/usr/local/bin/opj*
/usr/local/include/openjpeg-2.3

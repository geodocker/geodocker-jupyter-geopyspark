%define _topdir   /tmp/rpmbuild
%define name      netcdf
%define release   33
%define version   4.5.0

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   NetCDF
License:   X/MIT
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    netcdf-%{version}.tar.gz
Prefix:    /usr/local
Group:     Azavea
Requires:  libcurl
Requires:  hdf5
BuildRequires: libcurl-devel
BuildRequires: hdf5

%description
NetCDF

%prep
%setup -q -n netcdf-4.5.0

%build
./configure --prefix=/usr/local
nice -n 19 make -j$(grep -c ^processor /proc/cpuinfo)

%install
nice -n 19 make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
/usr/local/*

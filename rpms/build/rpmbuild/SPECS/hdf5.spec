%define _topdir   /tmp/rpmbuild
%define name      hdf5
%define release   33
%define version   1.8.20

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   HDF5
License:   X/MIT
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    hdf5-%{version}.tar.bz2
Prefix:    /usr/local
Group:     Azavea
Requires:  libcurl
BuildRequires: libcurl-devel

%description
HDF5

%prep
%setup -q -n hdf5-1.8.20

%build
./configure --prefix=/usr/local
nice -n 19 make -j$(grep -c ^processor /proc/cpuinfo)

%install
nice -n 19 make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
/usr/local/*

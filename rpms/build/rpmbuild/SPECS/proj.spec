%define _topdir   /tmp/rpmbuild
%define name      proj493
%define release   33
%define version   4.9.3

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   Proj4
License:   MIT
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    proj-%{version}.tar.gz
Prefix:    /usr/local
Group:     Azavea

%description
Proj 4.9.3

%prep
%setup -q -n proj-4.9.3

%build
./configure --prefix=/usr/local
nice -n 19 make -j$(grep -c ^processor /proc/cpuinfo)

%install
make DESTDIR=%{buildroot} install

%package lib
Group: Geography
Summary: Proj 4.9.3 libraries
%description lib
The libraries

%files
%defattr(-,root,root)
/usr/local/*

%files lib
%defattr(-,root,root)
/usr/local/lib/*

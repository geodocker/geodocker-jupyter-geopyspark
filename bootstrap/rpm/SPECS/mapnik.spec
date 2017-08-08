%define _topdir   /tmp/rpm
%define name      mapnik
%define release   33
%define version   v3.0.13

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
echo

%install
python scons/scons.py PYTHON=/usr/bin/python3.4 DESTDIR=%{buildroot} PREFIX=/usr -j 33 install

%files
%defattr(-,root,root)
/usr/*

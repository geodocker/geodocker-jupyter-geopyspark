%define _topdir   /tmp/rpmbuild
%define name      boost162
%define release   33
%define version   1_62_0

BuildRoot: %{buildroot}
Summary:   Boost
License:   Boost License
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    boost_%{version}.tar.bz2
Prefix:    /usr/local
Group:     Development/Libraries
Requires:  libstdc++64

%description
Boost 1.62

%prep
%setup -q -n boost_1_62_0

%build
./bootstrap.sh --with-python=python3.4 --with-python-version=3.4
./b2 --prefix=%{buildroot}/usr/local -j 33

%install
./b2 --prefix=%{buildroot}/usr/local -j 33 install

%package lib
Group: Development/Libraries
Summary: Boost libraries
%description lib
The libraries

%files
%defattr(-,root,root)
/usr/local/lib/*
/usr/local/include/*

%files lib
%defattr(-,root,root)
/usr/local/lib/*

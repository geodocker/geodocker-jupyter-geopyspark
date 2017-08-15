%define _topdir   /tmp/rpmbuild
%define name      proj
%define release   33
%define version   4.9.3

BuildRoot: %{buildroot}
Summary:   Proj
License:   MIT
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}-%{version}.tar.gz
Prefix:    /usr/local
Group:     Geography

%description
Proj

%prep
%setup -q

%build
./configure --prefix=/usr/local
make -k -j 33 || make

%install
make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
/usr/local/*

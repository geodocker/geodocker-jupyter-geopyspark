%define _topdir   /tmp/rpmbuild
%define name      nodejs
%define release   13
%define version   8.5.0

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   NodeJS
License:   node.js
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    node-v%{version}.tar.gz
Prefix:    /usr/local
Group:     Development

%description
Node.js 8.5.0

%prep
%setup -q -n node-v8.5.0

%build
./configure --prefix=/usr/local
make -j$(grep -c ^processor /proc/cpuinfo)

%install
make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
/usr/local/*

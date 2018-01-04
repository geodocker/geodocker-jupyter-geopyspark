%define _topdir   /tmp/rpmbuild
%define name      freetype2
%define release   33
%define version   2.8

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   FreeType
License:   GPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    freetype-%{version}.tar.gz
Prefix:    /usr/local
Group:     Typography

%description
FreeType 2.8

%prep
%setup -q -n freetype-2.8

%build
./configure --prefix=/usr/local --with-harfbuzz=no
nice -n 19 make -j$(grep -c ^processor /proc/cpuinfo)

%install
make DESTDIR=%{buildroot} install

%package lib
Group: Typography
Summary: FreeType libraries
%description lib
The libraries

%files
%defattr(-,root,root)
/usr/local/*

%files lib
%defattr(-,root,root)
/usr/local/lib/*

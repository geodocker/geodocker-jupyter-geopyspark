%define _topdir   /tmp/rpmbuild
%define name      freetype
%define release   33
%define version   2.8

BuildRoot: %{buildroot}
Summary:   FreeType
License:   GPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}-%{version}.tar.gz
Prefix:    /usr/local
Group:     Typography

%description
FreeType 2.8

%prep
%setup -q

%build
./configure --prefix=/usr/local --with-harfbuzz=no
make -j 33

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

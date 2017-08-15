%define _topdir   /tmp/rpmbuild
%define name      gcc
%define release   33
%define version   5.4.0

BuildRoot: %{buildroot}
Summary:   GCC
License:   GPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}-%{version}.tar.bz2
Prefix:    /usr/local
Group:     Development/Tools

%description
Gnu Compiler Collection 5.4.0

%prep
%setup -q

%build
tar axvf /archives/isl-0.16.1.tar.bz2
mv isl-0.16.1/ isl/
./configure --prefix=/usr/local --disable-nls --disable-multilib --disable-bootstrap --enable-linker-build-id --enable-languages='c,c++'
make -j 33

%install
make DESTDIR=%{buildroot} install

%package lib
Group: Development/Tools
Summary: GCC libraries
%description lib
The libraries

%files
%defattr(-,root,root)
/usr/local/bin/*
/usr/local/include/*
/usr/local/share/*
/usr/local/lib/*
/usr/local/lib64/*
/usr/local/libexec/*

%files lib
%defattr(-,root,root)
/usr/local/lib/*
/usr/local/lib64/*
/usr/local/libexec/*

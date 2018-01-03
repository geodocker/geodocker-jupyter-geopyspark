%define _topdir   /tmp/rpmbuild
%define name      s3fs-fuse
%define release   33
%define version   1.82

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   s3fs-fuse
License:   GPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    v1.82.tar.gz
Prefix:    /usr/local
Group:     Filesystems
Requires:  fuse
BuildRequires: automake
BuildRequires: curl-devel
BuildRequires: fuse
BuildRequires: fuse-devel
BuildRequires: libxml2-devel
BuildRequires: mailcap
BuildRequires: openssl-devel

%description
s3fs-fuse

%prep
%setup -q -n s3fs-fuse-1.82

%build
./autogen.sh
./configure --prefix=/usr/local --with-openssl
make

%install
make DESTDIR=%{buildroot} install

%files
%defattr(-,root,root)
/usr/local/*

%define _topdir   /tmp/rpmbuild
%define name      configurable-http-proxy
%define release   13
%define version   0.0.0

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   configurable-http-proxy
License:   BSD-3
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    configurable-http-proxy.tar
Prefix:    /usr/local
Group:     Development
AutoReq:   no
Requires:  pam
Requires:  nodejs
BuildRequires: nodejs
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%description
configurable-http-proxy

%prep
%setup -q -n configurable-http-proxy

%build
echo

%install
find /usr/local | sort > before.txt
npm install -g configurable-http-proxy
find /usr/local | sort > after.txt
tar cf /tmp/packages.tar $(diff before.txt after.txt | grep '^>' | cut -f2 '-d ')
cd %{buildroot}
tar axf /tmp/packages.tar

%files
%defattr(-,root,root)
/usr/local/*

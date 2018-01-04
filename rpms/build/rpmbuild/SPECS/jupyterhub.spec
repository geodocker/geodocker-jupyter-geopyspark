%define _topdir   /tmp/rpmbuild
%define name      jupyterhub
%define release   13
%define version   0.7.2

%define debug_package %{nil}

BuildRoot: %{buildroot}
Summary:   JupyterHub
License:   ?
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    jupyterhub.tar
Prefix:    /usr/local
Group:     Development
AutoReq:   no
Requires:  pam

%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

%description
JupyterHub 0.7.2

%prep
%setup -q -n jupyterhub

%build
echo

%install
find /usr/local/lib /usr/local/lib64 | grep -v geopyspark | grep 'site-packages/[^/]\+$' | sort > before.txt
find /usr/local/share /usr/local/bin | sort >> before.txt
pip3 install -r requirements-1.txt
unzip /archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip
cd ipykernel-629ac54cae9767310616d47d769665453619ac64
patch -p1 < ../patch.diff
pip3 install .
cd ..
pip3 install -r requirements-2.txt
find /usr/local/lib /usr/local/lib64 | grep -v geopyspark | grep 'site-packages/[^/]\+$' | sort > after.txt
find /usr/local/share /usr/local/bin | sort >> after.txt
echo /usr/local/lib/node_modules/configurable-http-proxy >> after.txt
tar cf /tmp/packages.tar $(diff before.txt after.txt | grep '^>' | cut -f2 '-d ')
cd %{buildroot}
tar axf /tmp/packages.tar
cd %{buildroot}/usr/local/bin
ln -s ../lib/node_modules/configurable-http-proxy/bin/configurable-http-proxy configurable-http-proxy

%files
%defattr(-,root,root)
/usr/local/*

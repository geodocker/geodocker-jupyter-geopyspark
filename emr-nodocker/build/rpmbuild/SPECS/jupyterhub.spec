%define _topdir   /tmp/rpmbuild
%define name      jupyterhub
%define release   13
%define version   0.7.2

BuildRoot: %{buildroot}
Summary:   JupyterHub
License:   ?
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    jupyterhub.tar
Prefix:    /usr/local
Group:     Development

%global __os_install_post    \
    /usr/lib/rpm/amazon/brp-compress \
    %{!?__debug_package:/usr/lib/rpm/amazon/brp-strip %{__strip}} \
    /usr/lib/rpm/amazon/brp-strip-static-archive %{__strip} \
    /usr/lib/rpm/amazon/brp-strip-comment-note %{__strip} %{__objdump} \
    /usr/lib/rpm/amazon/brp-python-hardlink \
    %{!?__jar_repack:/usr/lib/rpm/amazon/brp-java-repack-jars} \
%{nil}

%description
JupyterHub 0.7.2

%prep
%setup -q -n jupyterhub

%build
echo

%install
find /usr/local | grep 'site-packages/[^/]\+$' > before.txt
pip3 install -r requirements-1.txt
unzip /archives/ipykernel-629ac54cae9767310616d47d769665453619ac64.zip
cd ipykernel-629ac54cae9767310616d47d769665453619ac64
patch -p1 < ../patch.diff
pip3 install .
cd ..
pip3 install -r requirements-2.txt
pip3 install "https://github.com/jupyterhub/oauthenticator/archive/f5e39b1ece62b8d075832054ed3213cc04f85030.zip"
find /usr/local | grep 'site-packages/[^/]\+$' > after.txt
tar cvf /tmp/packages.tar $(diff before.txt after.txt | grep '^>' | cut -f2 '-d ')
cd %{buildroot}
tar axvf /tmp/packages.tar
cp -r /usr/local/lib/node_modules %{buildroot}/usr/local/lib/node_modules
mkdir -p %{buildroot}/usr/local/bin
cd %{buildroot}/usr/local/bin
cp /usr/local/bin/jupyterhub .
ln -s ../lib/node_modules/configurable-http-proxy/bin/configurable-http-proxy configurable-http-proxy
mkdir -p %{buildroot}/usr/local/share/
cp -r /usr/local/share/jupyter %{buildroot}/usr/local/share/

%files
%defattr(-,root,root)
/usr/local/bin/*
/usr/local/lib/*
/usr/local/lib64/*
/usr/local/share/*

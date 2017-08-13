%define _topdir   /tmp/rpmbuild
%define name      boost
%define release   33
%define version   1_64_0

BuildRoot: %{buildroot}
Summary:   Boost
License:   Boost License
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}_%{version}.tar.bz2
Prefix:    /usr/local
Group:     Development/Tools

%description
Boost 1.64

%prep
%setup -q -n boost_1_64_0

%build
./bootstrap.sh --with-python=python3.4 --with-python-version=3.4
./b2 --prefix=%{buildroot}/usr/local -j 33

%install
./b2 --prefix=%{buildroot}/usr/local -j 33 install


%files
%defattr(-,root,root)
/usr/local/lib/*
/usr/local/include/*

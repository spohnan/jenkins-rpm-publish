# Settings that might need to be updated
%define name                  jenkins-rpm-publish
%define version               1.0
%define buildroot             %{_topdir}/BUILD/%{name}-%{version}-root

# RPM Header info
Summary: An RPM containing scripts to assist with publishing RPMs built by jenkins to a yum repository
Name:      %{name}
Version:   %{version}
Release:   %{release}
BuildArch: noarch
BuildRoot: %{buildroot}
Source:    https://github.com/spohnan/jenkins-rpm-publish
URL:       https://github.com/spohnan/jenkins-rpm-publish
License:   MIT
requires:  createrepo, httpd

%description
An RPM containing scripts to assist with publishing RPMs built by jenkins to a yum repository

%prep
exit 0

%build
exit 0

%install
rm -fr %{buildroot}
cp -R %{_sourcedir}/jenkins-rpm-publish %{buildroot}

%clean
rm -fr %{buildroot}

%pre
exit 0

%post
exit 0

%files

%defattr(755,root,root)
/usr/local/bin/jenkins-publish-rpm.sh

%defattr(755,root,jboss)
/var/www/html/repos



%changelog
* Thu Jan 3 2013 Andrew Spohn <Andy@AndySpohn.com> - 1.0
- First packaging

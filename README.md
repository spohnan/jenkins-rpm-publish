jenkins-rpm-publish
===================

An RPM containing scripts to assist with publishing RPMs build by jenkins to a yum repository
hosted from a local Apache web server


Usage
=================
The example below uses [jenkins-rpm-build.rpm](https://github.com/spohnan/jenkins-rpm-build) and
this jenkins-rpm-publish capability to build an rpm and publish to a locally hosted yum repository.
This snippet would be copied into the Execute Shell text area available after adding the additional
build step.

    # Settings
    RPM_VERSIONS_TO_KEEP=3
    RPM_REPO_BASE=/var/www/html/repos/centos/6/custom
    RPM_NAME=jenkins-rpm-publish-*.rpm

    # Build and publish
    jenkins-build-rpm.sh
    jenkins-publish-rpm.sh $RPM_REPO_BASE/x86_64 RPMS/noarch $RPM_NAME $RPM_VERSIONS_TO_KEEP
    jenkins-publish-rpm.sh $RPM_REPO_BASE/SRPMS SRPMS $RPM_NAME $RPM_VERSIONS_TO_KEEP


Download
=================
Download [source](http://static-01.andyspohn.com/rpm/centos/6/jenkins-rpm-publish-1.0.src.rpm) rpm
or binary (noarch) rpm for [CentOS 6](http://static-01.andyspohn.com/rpm/centos/6/jenkins-rpm-publish-1.0.noarch.rpm)


Building
=================
Clone this project into PROJECT_DIR

    git clone https://github.com/spohnan/jenkins-rpm-publish.git

Build the RPM

    rpmbuild \
        --define "release `date +%Y%m%d%H%M%S`" \
        --define "_topdir $PROJECT_DIR/jenkins-rpm-publish" \
        -ba SPECS/jenkins-rpm-publish.spec
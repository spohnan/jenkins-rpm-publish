jenkins-rpm-publish
===================

An RPM containing scripts to assist with publishing RPMs build by jenkins to a yum repository
hosted from a local Apache web server


Usage
=================


Building
=================
Clone this project into PROJECT_DIR

    git clone https://github.com/spohnan/jenkins-rpm-publish.git

Build the RPM

    rpmbuild \
        --define "release `date +%Y%m%d%H%M%S`" \
        --define "_topdir $PROJECT_DIR/jenkins-rpm-publish" \
        -ba SPECS/jenkins-rpm-publish.spec
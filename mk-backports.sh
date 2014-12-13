#!/bin/bash
set -e

# check dependencies
for i in dpkg-source dch patch; do
    if ! which $i > /dev/null 2>&1; then
        echo "You need the following packages installed for generating backports:"
        echo "dpkg-dev devscripts patch"
        exit 1
    fi
done

apt-get source --download-only -t unstable wireshark
DSC=$(ls wireshark_*.dsc| grep -v '~')

for dist in precise trusty; do
    dpkg-source -x $DSC
    cd wireshark-*
    dch -b -v $(dpkg-parsechangelog -S Version)'~'${dist}1 --force-distribution -D ${dist} "Rebuild for ${dist^}"
    dch -a "Changed build-dependencies to packages available in ${dist^}"
    patch -p1 < ../${dist}.patch
    dpkg-buildpackage -S -d -us -uc
    cd ..
    rm -rf wireshark-*
done

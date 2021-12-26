#!/usr/bin/env bash

set -xeuo pipefail

# BUG: https://github.com/projectatomic/rpm-ostree/issues/1542#issuecomment-419684977
for x in /etc/yum.repos.d/*modular.repo; do
    sed -i -e 's,enabled=[01],enabled=0,' ${x}
done

# BUG: https://bugzilla.redhat.com/show_bug.cgi?id=1265295
if ! grep -q '^Storage=persistent' /etc/systemd/journald.conf; then
    (cat /etc/systemd/journald.conf && echo 'Storage=persistent') > /etc/systemd.journald.conf.new
    mv /etc/systemd.journald.conf{.new,}
fi

# SEE: https://src.fedoraproject.org/rpms/glibc/pull-request/4
# Basically that program handles deleting old shared library directories
# mid-transaction, which never applies to rpm-ostree. This is structured as a
# loop/glob to avoid hardcoding (or trying to match) the architecture.
for x in /usr/sbin/glibc_post_upgrade.*; do
    if test -f ${x}; then
        ln -srf /usr/bin/true ${x}
    fi
done

sed -i "s/^\(NAME=\)\"\(.*\)\"$/\1\"Fedora Sodalite\"/g" /etc/os-release
sed -i "s/^\(PRETTY_NAME=\)\"\(.*\)\"$/\1\"Fedora Sodalite 35.0\"/g" /etc/os-release
sed -i "s/^\(VERSION=\)\"\(.*\)\"$/\1\"35.0 Japurá\"/g" /etc/os-release
echo "VARIANT=\"Sodalite\"" >> /etc/os-release
echo "VARIANT_ID=sodalite" >> /etc/os-release
echo "VERSION_CODENAME=japura" >> /etc/os-release

ln -s /usr/share/backgrounds/sodalite/karsten-wurth-7BjhtdogU3A-unsplash.jpg /usr/share/backgrounds/elementaryos-default

glib-compile-schemas /usr/share/glib-2.0/schemas
systemctl enable sodalite-generate-oem
systemctl enable sodalite-install-appcenter-flatpak
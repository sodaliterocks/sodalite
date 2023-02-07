#!/usr/bin/env bash

# TODO: Work out if we even need some of these, as the related issues are
#       pretty old.

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

if [[ $_os_core == "pantheon" ]]; then
    # Some hacks for libayatana to work properly. Might stop working one day.
    ln -s /usr/lib64/libwingpanel.so.3 /usr/lib64/libwingpanel-2.0.so.0
    sed -i 's/lib\/x86_64-linux-gnu/lib64/g' /etc/xdg/autostart/indicator-application.desktop
fi

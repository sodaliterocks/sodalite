#!/usr/bin/env bash

# TODO: Work out if we even need some of these, as the related issues are
#       pretty old.

if [[ $_os_base_version == "38" ]]; then
    # BUG: https://github.com/projectatomic/rpm-ostree/issues/1542#issuecomment-419684977
for x in /etc/yum.repos.d/*modular.repo; do
    sed -i -e 's,enabled=[01],enabled=0,' ${x}
done

    # Work around https://bugzilla.redhat.com/show_bug.cgi?id=1265295
    # From https://github.com/coreos/fedora-coreos-config/blob/testing-devel/overlay.d/05core/usr/lib/systemd/journald.conf.d/10-coreos-persistent.conf
    install -dm0755 /usr/lib/systemd/journald.conf.d/
    echo -e "[Journal]\nStorage=persistent" > /usr/lib/systemd/journald.conf.d/10-persistent.conf

    # See: https://src.fedoraproject.org/rpms/glibc/pull-request/4
    # Basically that program handles deleting old shared library directories
    # mid-transaction, which never applies to rpm-ostree. This is structured as a
    # loop/glob to avoid hardcoding (or trying to match) the architecture.
    for x in /usr/sbin/glibc_post_upgrade.*; do
        if test -f ${x}; then
            ln -srf /usr/bin/true ${x}
        fi
    done

    # Remove loader directory causing issues in Anaconda in unified core mode
    # Will be obsolete once we start using bootupd
    rm -rf /usr/lib/ostree-boot/loader
fi

if [[ $_os_base_version == "39" ]]; then
    # Work around https://bugzilla.redhat.com/show_bug.cgi?id=1265295
    # From https://github.com/coreos/fedora-coreos-config/blob/testing-devel/overlay.d/05core/usr/lib/systemd/journald.conf.d/10-coreos-persistent.conf
    install -dm0755 /usr/lib/systemd/journald.conf.d/
    echo -e "[Journal]\nStorage=persistent" > /usr/lib/systemd/journald.conf.d/10-persistent.conf

    # See: https://src.fedoraproject.org/rpms/glibc/pull-request/4
    # Basically that program handles deleting old shared library directories
    # mid-transaction, which never applies to rpm-ostree. This is structured as a
    # loop/glob to avoid hardcoding (or trying to match) the architecture.
    for x in /usr/sbin/glibc_post_upgrade.*; do
        if test -f ${x}; then
            ln -srf /usr/bin/true ${x}
        fi
    done

    # Remove loader directory causing issues in Anaconda in unified core mode
    # Will be obsolete once we start using bootupd
    rm -rf /usr/lib/ostree-boot/loader

    # Undo RPM scripts enabling units; we want the presets to be canonical
    # https://github.com/projectatomic/rpm-ostree/issues/1803
    rm -rf /etc/systemd/system/*
    systemctl preset-all
    rm -rf /etc/systemd/user/*
    systemctl --user --global preset-all

    # Workaround for https://bugzilla.redhat.com/show_bug.cgi?id=2218006
    systemctl enable nfs-client.target
fi

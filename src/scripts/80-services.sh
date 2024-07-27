#!/usr/bin/env bash

if [[ $_os_core == "pantheon" ]]; then
    #systemctl disable gdm
    systemctl enable generate-oemconf
    [[ $_os_base_version != "38" ]] && systemctl enable lightdm
    systemctl enable touchegg
    systemctl --global enable io.elementary.files.xdg-desktop-portal
fi

systemctl enable sodalite-migrate

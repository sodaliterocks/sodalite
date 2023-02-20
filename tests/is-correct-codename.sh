#!/usr/bin/env bash

os_codename="$(ost cat $commit /usr/lib/os-release | grep "VERSION_CODENAME=" | tail -1 | sed -e "s/VERSION_CODENAME=//" -e "s/\"//g")"
os_version="$(ost cat $commit /usr/lib/os-release | grep "OSTREE_VERSION" | sed -e "s/OSTREE_VERSION=//" -e "s/'//g" -e "s/-.*//")"
check_codename=""

function get_codename() {
    case "$1" in
        "4.0"*) echo "Nubia" ;;
        "4.1"*) echo "Toniki" ;;
        "5.0"*) echo "Iberia" ;;
    esac
}

if [[ "$(get_codename $os_version)" == "$os_codename" ]]; then
    echo "true"
else
    echo "Incorrect codename (Is: $os_codename / Should: $(get_codename $os_version))"
fi

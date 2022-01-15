#!/usr/bin/env bash

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite/bash/common.sh
else
    . "$(dirname "$(realpath -s "$0")")/../../../lib/sodaliterocks.common/bash/common.sh"
fi

NEW_STATIC_HOSTNAME=$1
NEW_PRETTY_HOSTNAME=$2

test_root

if { [[ -n $NEW_STATIC_HOSTNAME ]] && [[ $NEW_STATIC_HOSTNAME != "reset" ]]; }; then
    echo "Setting hostname to '$NEW_STATIC_HOSTNAME'..."
    hostnamectl hostname $NEW_STATIC_HOSTNAME

    if [[ -n $NEW_PRETTY_HOSTNAME ]]; then
        echo "Setting description to '$NEW_PRETTY_HOSTNAME'"
        hostnamectl hostname "$NEW_PRETTY_HOSTNAME" --pretty
    else
        hostnamectl hostname "" --pretty
    fi
else
    echo "Restting hostname..."
    hostnamectl hostname ""
    hostnamectl hostname "" --pretty
    hostnamectl hostname "" --transient
fi

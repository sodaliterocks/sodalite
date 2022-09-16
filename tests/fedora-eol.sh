#!/usr/bin/env bash

function is_eol() {
    let diff=($(date +%s -d $1)-$(date +%s))/86400

    if (( $diff > 0 )); then
        echo "false"
    else
        echo "true"
    fi
}

fedora_release="$(ost cat $commit /usr/lib/fedora-release | sed "s/Fedora release //" | sed "s/ (.*//")"
eol="true"

case $fedora_release in
    34) eol=$(is_eol 20220607) ;;
    35) eol=$(is_eol 20221115) ;;
    36) eol=$(is_eol 20230516) ;;
    37) eol=$(is_eol 20231114) ;;
    38) eol=$(is_eol 20240514) ;;
    *)
        if (( $fedora_release > 38 )); then
            eol="false"
        fi
    ;;
esac

if [[ $eol == "true" ]]; then
    echo "false"
else
    echo "true"
fi

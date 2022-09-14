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
eol="false"

case $fedora_release in
    34) eol=$(is_eol 20220601) ;;
    35) eol=$(is_eol 20221207) ;;
    36) eol=$(is_eol 20230516) ;;
    37) eol=$(is_eol 20231122) ;;
    38) eol=$(is_eol 20240514)
    *) eol="true" ;;
esac

if [[ $eol == "true" ]]; then
    echo "false"
else
    echo "true"
fi

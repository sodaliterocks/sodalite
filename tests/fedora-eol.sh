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
    35) eol=$(is_eol 20221213) ;;
    36) eol=$(is_eol 20230516) ;;
    37) eol=$(is_eol 20231114) ;;
    38) eol=$(is_eol 20240514) ;; # last checked: 9-Nov-2023 (https://fedorapeople.org/groups/schedule/f-40/f-40-key-tasks.html)
    39) eol=$(is_eol 20241112) ;; # last checked: 9-Nov-2023 (https://fedorapeople.org/groups/schedule/f-41/f-41-key-tasks.html)
    40) eol=$(is_eol 20250513) ;; # last checked: 9-Nov-2023 (https://fedorapeople.org/groups/schedule/f-42/f-42-key-tasks.html)
    *)
        if (( $fedora_release > 40 )); then
            eol="false"
        fi
    ;;
esac

if [[ $eol == "true" ]]; then
    echo "Fedora Linux $fedora_release is EoL"
else
    echo "true"
fi

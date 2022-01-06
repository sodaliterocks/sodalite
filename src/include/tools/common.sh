#!/usr/bin/env bash

ERROR_NOT_ROOT=1

function echoc() {
    MESSAGE=${@:2}
    TYPE=$1

    PREFIX=""
    PREFIX_COLOR=""

    case $TYPE in
        error)
            PREFIX="error"
            PREFIX_COLOR="31"
        ;;
        debug)
            if [[ $SODALITE_TOOLS_DEBUG == true ]]; then
                PREFIX="debug"
                PREFIX_COLOR="33"
            else
                MESSAGE=""
            fi
        ;;
        *)
            MESSAGE="$TYPE $MESSAGE"
        ;;
    esac

    if [[ -n $PREFIX ]]; then
        MESSAGE="\033[1;${PREFIX_COLOR}m${PREFIX}:\033[0m $MESSAGE"
    fi

    if [[ -n $MESSAGE ]]; then
        echo -e "$MESSAGE"
    fi
}

function get_answer() {
    QUESTION=$@

    if [[ ! -n $QUESTION ]]; then
        QUESTION="Continue?"
    fi

    while true; do
        read -p "$QUESTION [Y/n]: " ANSWER
        case $ANSWER in
            [Yy]* ) echo true; return ;;
            [Nn]* ) echo false; return ;;
            * ) ;;
        esac
    done
}

function get_cpu_vendor() {
    cpu_vendor=$(cat /proc/cpuinfo | grep vendor_id | uniq)
    cpu_vendor=${cpu_vendor#*\:}

    echo $cpu_vendor
}

function get_hwinfo() {
    key=$1
    type=$2

    [[ -z $type ]] && type="1"

    sudo dmidecode -t$type | grep "$key:" | sed 's/\t'"${key}"': //g'
}

function set_export() {
    if [[ ! -n $(eval "echo \$$1") ]]; then
        eval "$1"='$2'
    fi
}

function test_root() {
    CURRENT_UID=$(id -u)
    if ! [ $CURRENT_UID = 0 ]; then
        echoc debug "UID is $CURRENT_UID"
        echoc error "Permission denied (are you root?)"
        exit $ERROR_NOT_ROOT
    fi
}

set_export SODALITE_TOOLS_DEBUG false

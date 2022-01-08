#!/usr/bin/env bash

ERROR_NOT_ROOT=1

OSTREE_REMOTE_REPO_BASE="https://ostree.zio.sh"
OSTREE_REMOTE_REPO="$OSTREE_REMOTE_REPO_BASE/repo/"

REGEX_OSTREE_REF="(fedora\/([A-Za-z0-9]{1,})\/([A-Za-z0-9\_]{1,})\/([A-Za-z0-9\-]{1,}))"

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

function get_http_code() {
    url=$1
    echo $(curl -s -o /dev/null --head -w "%{http_code}" "$url")
}

function get_hwinfo() {
    key=$1
    type=$2

    [[ -z $type ]] && type="1"

    value=$(dmidecode -t$type | grep "$key:" | sed 's/\t'"${key}"': //g')

    if [[ -z value ]]; then
        echo "Unknown $key"
    else
        echo $value
    fi
}

function get_latest_major_ref() {
    current_ref=$1
    latest_ref=""

    if [[ $(get_http_code "$OSTREE_REMOTE_REPO") == "200" ]]; then
        latest_version=0

        if [[ $current_ref =~ $REGEX_OSTREE_REF ]]; then
            current_arch=${BASH_REMATCH[3]}
            current_variant=${BASH_REMATCH[4]}
            current_version=${BASH_REMATCH[2]}
            latest_version=$current_version
            next_version=$current_version

            if [[ $current_version == ?(-)+([:digit:]) ]]; then
                found_latest=false
                while [ $found_latest == false ]
                do
                    next_version=$(expr $current_version + 1)
                    next_commit=$(get_latest_minor_commit "fedora/$next_version/$current_arch/$current_variant")

                    if [[ -z $next_commit ]]; then
                        found_latest=true
                    else
                        latest_version=$(expr $next_version - 1)
                    fi
                done

                [[ $found_latest == true ]] && latest_ref="fedora/$latest_version/$current_arch/$current_variant"
            fi
        fi
    fi

    if [[ -z $latest_ref ]]; then
        echo "$current_ref"
    else
        echo $latest_ref
    fi
}

function get_latest_minor_commit() {
    ref=$1

    if [[ $(get_http_code "$OSTREE_REMOTE_REPO") == "200" ]]; then
        found_commit=$(curl -s "$OSTREE_REMOTE_REPO/refs/heads/$ref")
        [[ ${#found_commit} == 64 ]] && echo $found_commit
    fi
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

function write_emoji() {
    emoji=$1
    emoji_length=${#emoji}
    
    case $emoji_length in
        3) echoc "$emoji  " ;;
        2) echoc "$emoji " ;;
        *) echoc "$emoji" ;;
    esac
}

set_export SODALITE_TOOLS_DEBUG false

#!/usr/bin/env bash

# 1) Install Fedora Silverblue, or any other Fedora OSTree variant
# 2) Run 'curl -s https://git.zio.sh/sodalite/sodalite-ostree/raw/branch/master/install.sh | bash'
# 3) Reboot
# 4) ???
# 5) PROFIT!

# TODO: Check if Sodalite has already been pulled
# TODO: Check if we're currently on Sodalite (if we are, upgrade)
# TODO: Populate $VERSION automagically
# TODO: Option to use local build?

if ! [ $(id -u) = 0 ]; then
   echo "Must be ran as root!"
   exit 1
fi

function echo_error() {
    echo -e "\033[1;31m$1\033[0m"
}

function echo_logo_line() {
    echo -e "\033[1;36m$1\033[0m"
}

function prompt_yn() {
    QUESTION=$1
    YES_CMD=$2
    NO_CMD=$3

    while true; do
    read -p "$QUESTION [Y/n]: " ANSWER
    case $ANSWER in
        [Yy]* ) eval $YES_CMD;;
        [Nn]* ) eval $NO_CMD;;
        * ) ;;
    esac
done

}

ARCH="$(uname -m)"
PWD="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REMOTE_NAME="zio"
REMOTE_URL="https://ostree.zio.sh/repo"
VARIANT="sodalite"
VERSION="35"

REF="$REMOTE_NAME:fedora/$VERSION/$ARCH/$VARIANT"

echo_logo_line " ____            _       _ _ _"
echo_logo_line "/ ___|  ___   __| | __ _| (_| |_ ___"
echo_logo_line '\___ \ / _ \ / _` |/ _` | | | __/ _ \\'
echo_logo_line " ___) | (_) | (_| | (_| | | | ||  __/"
echo_logo_line "|____/ \___/ \__,_|\__,_|_|_|\__\___|"
echo ""

#          --------------------------------------------------------------------------------
echo -e "This script will install, or \"rebase\" Sodalite onto your current Fedora OSTree"
echo -e "installation. As with any rebase this can easily be reversed by calling"
echo -e "'rpm-ostree rollback'. This script is intended to make it quick to install Fedora"
echo -e "Sodalite but a basic knowledge of OSTree and/or Fedora Silverblue is recommended"
echo -e "should issues arise. Docs for Fedora Silverblue can be found at"
echo -e "https://docs.fedoraproject.org/en-US/fedora-silverblue/.\n"

if ! { [[ -d "/sysroot" ]] && [[ -d "/sysroot/ostree" ]] && [[ "$(command -v rpm-ostree)" ]]; }; then
    echo_error "This is not Fedora OSTree. Exiting..."
    exit
fi

if [[ "$ARCH" != "x86_64" ]]; then
    echo_error "Architecture $ARCH not supported. Exiting...\n"
    exit
fi

if [[ -d "$PWD/build" ]]; then
    #           --------------------------------------------------------------------------------
    echo_error "This script does not use your local build, but the hosted production version"
    echo_error "of Sodalite. Please refer to OSTree documentation if you wish to use a local"
    echo_error "OSTree repository.\n"
fi

prompt_yn "Do you wish to continue?" \
    'break' \
    'echo "Aw, okay :("; exit'
echo ""

echo "Adding $REMOTE_NAME OSTree remote..."
ostree remote add --if-not-exists $REMOTE_NAME $REMOTE_URL --no-gpg-verify

echo "Pulling $REF..."
ostree pull $REF

echo "Rebasing OS to $REF..."
rpm-ostree rebase $REF

echo ""
prompt_yn "Complete! Do you want to reboot now?" \
    'echo "See you on the other side!"; shutdown -r now' \
    'exit'


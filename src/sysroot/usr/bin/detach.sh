#!/usr/bin/env bash

# Useful lil' tool for running stuff from the terminal but not having it stay
# there and vomit up its logs and other nonsense

command=$@
log="/dev/null"

"$command" &>$log & disown

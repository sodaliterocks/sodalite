#!/usr/bin/env bash

command=$@
log="/dev/null"

"$command" &>$log & disown

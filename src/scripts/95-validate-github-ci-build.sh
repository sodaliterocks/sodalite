#!/usr/bin/env bash

if [[ $(get_buildopt "github-ci-build") == true ]]; then
    echo "Hello GitHub :)"
fi

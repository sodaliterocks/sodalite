#!/usr/bin/env bash

if [[ $(get_buildopt "github-ci-build") == true ]];
    echo "Hello GitHub :)"
fi

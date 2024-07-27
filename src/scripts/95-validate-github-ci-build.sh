#!/usr/bin/env bash

if [[ $(get_buildopt "github-ci-build") == true ]]; then
    valid_ci_build=true
    ci_build_problems=()

    [[ "$(get_property /usr/lib/os-release VENDOR)" != "sodaliterocks" ]] && ci_build_problems+="VENDOR (--vendor) not set to 'sodaliterocks'"

    for ci_build_problem in "${ci_build_problems[@]}"; do
        echo "   ⤷ $ci_build_problem"
        valid_ci_build=false
    done

    if [[ $valid_ci_build == false ]]; then
        exit 255
    fi
fi

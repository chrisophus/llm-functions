#!/usr/bin/env bash
set -e

# @env LLM_OUTPUT=/dev/stdout The output path

# See more details at https://github.com/sigoden/argc
eval "$(argc --argc-eval "$0" "$@")" 
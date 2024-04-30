#!/bin/bash
ACTION_DIR="./.github-release-matrix-action"
rm -rf "$ACTION_DIR"
mkdir -p "$ACTION_DIR"

export RUNNER_TEMP="${ACTION_DIR}/tmp"
export GITHUB_OUTPUT="${ACTION_DIR}/GITHUB_OUTPUT"
mkdir -p "$RUNNER_TEMP"
touch "$GITHUB_OUTPUT"

exec ./action.sh "cli/cli" "${@}"

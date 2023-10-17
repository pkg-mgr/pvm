#!/bin/bash

# Sets the current version of pnpm to use for the current shell session.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

version=${1:-}
if [ -z "$version" ]; then
  echo "No version provided. Please supply a version number. (ex: pnpmvm use 8.9.2)"
  exit 1
fi

# Write the version to a temporary file that includes the parent PID so that further commands in this terminal can use it
if [ -z "${pnpmvm_parent_pid+x}" ]; then
  parent_pid=$$
else
  parent_pid=$pnpmvm_parent_pid
fi
tmp_version_file="/tmp/PNPMVM_VERSION_$parent_pid"
echo "$version" > "$tmp_version_file"
echo "Using version: $version via $tmp_version_file"

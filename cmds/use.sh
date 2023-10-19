#!/bin/bash

# Sets the current version of pnpm to use for the current shell session.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

version=$(./cmds/resolve_version.sh "${1:-}")

# Check if the version is already installed
if [ ! -f "$HOME/.pnpmvm/$version/pnpm" ]; then
  echo "Version $version is not installed. Please install it first. (pvm install $version)"
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

if [ "$PNPMVM_DEBUG" = "true" ]; then
  echo "DEBUG: Wrote version $version to $tmp_version_file"
fi
echo "Now using version: $version"

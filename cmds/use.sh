#!/bin/bash

# Sets the current version of pnpm to use for the current shell session.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pvm"
cmds_dir="$base_dir/cmds"
version=$("$cmds_dir/resolve_version.sh" "${1:-}")

# Check if the version is already installed
if [ ! -f "$HOME/.pvm/$version/pnpm" ]; then
  echo "Version $version is not installed. Please install it first. (pvm install $version)"
  exit 1
fi

# Write the version to a temporary file that includes the parent PID so that further commands in this terminal can use it
if [ -z "${pvm_parent_pid+x}" ]; then
  parent_pid=$$
else
  parent_pid=$pvm_parent_pid
fi
tmp_version_file="/tmp/pvm_VERSION_$parent_pid"
echo "$version" > "$tmp_version_file"

if [ "$pvm_DEBUG" = "true" ]; then
  echo "DEBUG: Wrote version $version to $tmp_version_file"
fi
echo "Now using version: $version"

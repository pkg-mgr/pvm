#!/bin/bash

# Unsets the current version of pnpm for the current shell session.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pvm"
default_version_file="$base_dir/default-version.txt"

# Remove the temporary file that includes the parent PID
if [ -z "${pvm_parent_pid+x}" ]; then
  parent_pid=$$
else
  parent_pid=$pvm_parent_pid
fi
tmp_version_file="/tmp/pvm_VERSION_$parent_pid"
rm -f "$tmp_version_file"

if [[ -f $default_version_file ]]; then
    default_version=$(cat "$default_version_file")
fi

if [ "$PVM_DEBUG" = "true" ]; then
  echo "DEBUG: Removed version file $tmp_version_file"
fi

echo "Unused the current version."
if [[ -z ${default_version+x} ]]; then
    echo "No default version detected. pvm will now check for a .pvmrc file if it exists, otherwise it pnpm commands will fail."
else
    echo "pvm will now default to version $default_version to unless a .pvmrc file exists"
fi

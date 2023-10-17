#!/bin/bash

# Sets the default pnpm version for the current shell session.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

version=${1:-}
base_dir="$HOME/.pnpmvm"
default_version_file="$base_dir/default-version.txt"

# if no version is provided, report the current version instead
if [ -z "$version" ]; then
  if [ -f "$default_version_file" ]; then
    default_version=$(head -n 1 "$default_version_file")
	 echo "Current default version: $default_version"
  else
	 echo "No default version set."
  fi
fi

# Assume version is semantic for now. In the future, support latest6, latest7, latest8, latest, etc.
echo "$version" > "$default_version_file"
echo "Wrote version $version to $default_version_file"

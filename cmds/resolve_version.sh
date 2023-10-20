#/bin/bash

# Checks for single-digit major inputs and returns full version numbers

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

find_version() {
  # The first argument is the major version number
  local major_version=$1

  # Read the file and find the line
  resolved_major=$(grep "^$major_version\." "$HOME/.pvm/versions.txt" | grep "^[0-9\.-]*$" | tail -n 1)

  # Return the result
  echo "$resolved_major"
}

# checks to see if input is a single positive major version integer
# if yes, goes to find the latest of that major and set version to the latest
if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+([-.\w]*)$ ]]; then
  # matches `6.32.4` or `7.0.0-rc.0`
  # semantic version specified
  echo $1

  elif [[ $1 =~ ^[0-9]$ ]] && (($1 > 0)); then
  # Major version specified
  echo $(find_version "$1")

  else
  echo "
      Invalid version format.
      Enter an existing major version or a semantic version.
      Example:
      pvm install 8
      pvm use 6.17.1
  " > `tty`
  exit 1
fi

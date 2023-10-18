#!/bin/bash

# Integration test suite.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pnpmvm"

error_if_file_exists() {
  if [[ -f $1 ]]; then
    echo "File exists $1"
    exit 1
  fi
}

error_if_dir_exists() {
  if [[ -d $1 ]]; then
    echo "Directory exists $1"
    exit 1
  fi
}

file_should_exist() {
  if [[ ! -f $1 ]]; then
    echo "File does not exist $1"
    exit 1
  fi
}

cmd_should_exist() {
  if ! command -v "$1" &> /dev/null; then
    echo "missing command: $1"
  fi
}

uninstall_pnpmvm() {
  echo "y" | ./cmds/nuke.sh
  error_if_dir_exists "$base_dir"
  error_if_file_exists "/usr/local/bin/pnpm"
  error_if_file_exists "/usr/local/bin/pnpmvm"
  error_if_file_exists "/usr/local/bin/pvm"
}

check_pvm_default_version() {
  local expected_version=$1
  default_version_output=$(pvm default)
  if [[ ! $default_version_output == "Current default version: $expected_version" ]]; then
    echo "Current default version $default_version_output doesn't match expected version $expected_version"
    exit 1
  fi
}

check_current_pnpm_version() {
  local expected_version=$1
  pnpm_version=$(pnpm --version)
  if [[ ! $pnpm_version == "$expected_version" ]]; then
    echo "Current pnpm version $pnpm_version doesn't match expected version $expected_version"
    exit 1
  fi
}

echo "*** Initial setup, removing any existing install..."
uninstall_pnpmvm

echo "*** Installing pnpmvm..."
./setup.sh

echo "Check that base commands exist..."
cmd_should_exist "pnpmvm"
cmd_should_exist "pnpm"
cmd_should_exist "pvm"

echo "Test installing a specific version..."
pvm install 8.9.2
file_should_exist "$base_dir/8.9.2/pnpm"
echo "Checking that default version has been set..."
check_pvm_default_version "8.9.2"
echo "Checking that current pnpm version is correct..."
check_current_pnpm_version "8.9.2"

echo "*** All tests passed! ***"

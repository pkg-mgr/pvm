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

dir_should_exist() {
  if [[ ! -d $1 ]]; then
    echo "Directory does not exist $1"
    exit 1
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
  if [[ ! $default_version_output == "$expected_version" ]]; then
    echo "Output '$default_version_output' doesn't match expected '$expected_version'"
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

function check_output_contains_str() {
  if [[ "$2" != *"$1"* ]]; then
    echo "Expected string not detected."
    echo "Expected: $1"
    echo "Received: $2"
    exit 1
  fi
}

### Beginning of Tests ###

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

echo "Test installing a major version..."
pvm install 7
file_should_exist "$base_dir/7.9.5/pnpm"
check_current_pnpm_version "7.9.5"

echo "Test that pvm list shows both versions..."
list_output=$(pvm list > /dev/null 2>&1)
check_output_contains_str "$list_output" "8.9.2"
check_output_contains_str "$list_output" "7.9.5"

echo "Test using a different version..."
pvm use 8.9.2
check_current_pnpm_version "8.9.2"
pvm use 7.9.5
check_current_pnpm_version "7.9.5"

echo "Test unusing, should fall back to default version..."
pvm unuse
check_current_pnpm_version "8.9.2"

echo "Test changing the default version..."
pvm default 7.9.5
check_current_pnpm_version "7.9.5"

echo "Test uninstalling a version..."
pvm uninstall 7.9.5
error_if_dir_exists "$base_dir/7.9.5"

echo "Installing an invalid version should not work or delete anything else."
pvm install 3 > /dev/null 2>&1 || true # ignore err
dir_should_exist "$base_dir"
dir_should_exist "$base_dir/8.9.2"

echo "Help command should display text..."
help_output=$(pvm help > /dev/null 2>&1)
check_output_contains_str "$help_output" "Available commands:"

echo "*** All tests passed! ***"

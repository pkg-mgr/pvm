#!/bin/bash

# Integration test suite.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pvm"
pkg_dir="$HOME/.pnpm-store"

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

uninstall_pvm() {
  echo "y" | ./cmds/nuke.sh
  error_if_dir_exists "$base_dir"
  error_if_file_exists "/usr/local/bin/pnpm"
  error_if_file_exists "/usr/local/bin/pvm"
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
  if [ -z "$2" ]; then
    echo "Error: no string to check for."
    exit 1
  fi
  if [[ "$1" != *"$2"* ]]; then
    echo "Test failure - Expected string not detected."
    echo "EXPECTED: $1"
    echo "RECEIVED: $2"
    exit 1
  fi
}

function on_error {
  exit_status=$?
  if [ $exit_status -eq 0 ]; then
    echo "*** All Tests Passed! ***"
  else
    echo "*** TEST FAILURE ***"
  fi
}

trap on_error EXIT

### Beginning of Tests ###

echo "*** Initial setup, removing any existing install..."
uninstall_pvm

echo "*** Installing pvm..."
./setup.sh

echo "Check that base commands exist..."
cmd_should_exist "pvm"
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
list_output=$(pvm list 2>&1)
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

echo "Help command should display text..."
help_output=$(pvm help 2>&1)
check_output_contains_str "$help_output" "Available commands:"

echo "Check that invalid commands display the help info..."
invalid_cmd_output=$(pvm invalid_command 2>&1) || true # ignore err
check_output_contains_str "$invalid_cmd_output" "Available commands:"

echo "Test pnpm add -g cowsay..."
rm -f "$pkg_dir/cowsay"
error_if_file_exists "$pkg_dir/cowsay"
pnpm add -g cowsay
file_should_exist "$pkg_dir/cowsay"

echo "Test pnpx cowsay hello..."
cowsay_output=$(pnpx cowsay "hello")
check_output_contains_str "$cowsay_output" "< hello >"

echo "Test pnpm exec cowsay Moo..."
cowsay_output=$(pnpm exec cowsay Moo)
check_output_contains_str "$cowsay_output" "< Moo >"

echo "Test pnpm remove -g cowsay..."
file_should_exist "$pkg_dir/cowsay"
pnpm remove -g cowsay
error_if_file_exists "$pkg_dir/cowsay"

echo "Test uninstalling a version..."
pvm uninstall 7.9.5
error_if_dir_exists "$base_dir/7.9.5"

echo "Installing an invalid version should not work or delete anything else..."
pvm install 3 2>&1 || true # ignore err
dir_should_exist "$base_dir"
dir_should_exist "$base_dir/8.9.2"

echo "*** Tests within a repo ***"
cd repo-test-1
rm -rf node_modules

echo "Test .pvmrc file takes precidence over default version..."
# (default version would still be 7.9.5 from above, which was uninstalled)
check_current_pnpm_version "8.9.2"

echo "Test pnpm install..."
error_if_dir_exists "./node_modules"
pnpm install
dir_should_exist "./node_modules"

echo "Test running a script defined in package.json..."
script_output=$(pnpm hi)
check_output_contains_str "$script_output" "< hi >"

echo "Test running a node script with a local dependency..."
script_output=$(pnpm test1)
check_output_contains_str "$script_output" "< I'm a moooodule >"

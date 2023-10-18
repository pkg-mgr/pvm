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

echo "*** Initial setup, removing any existing install..."
uninstall_pnpmvm

echo "*** Installing pnpmvm..."
./setup.sh

echo "Check that base commands exist..."
cmd_should_exist "pnpmvm"
cmd_should_exist "pnpm"
cmd_should_exist "pvm"

echo "*** All tests passed! ***"

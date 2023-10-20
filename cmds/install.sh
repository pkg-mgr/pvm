#!/bin/bash

# Installs a specified pnpm binary (or defaults to the latest).

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pvm"
cmds_dir="$base_dir/cmds"
default_version_file="$base_dir/default-version.txt"

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "Created directory $1"
  fi
}

function remove_dir() {
  dir_path=$1
  if [[ $dir_path == $base_dir/* ]]; then
    if [ -d "$dir_path" ]; then
      rm -rf "$dir_path"
      echo "Removed folder: $dir_path"
    fi
  else
    echo "Error: Cannot remove folders outside of $base_dir"
    exit 1
  fi
}

function download_and_untar() {
  local url="$1"
  local dir="$2"
  
  # Create the directory if it doesn't exist
  ensure_dir "$dir"
  
  # Use curl to download the file and pipe it to tar to extract
  curl -L "$url" | tar -xz -C "$dir" --strip-components=1
  # (--strip-components=1 removes the top-level directory from the archive)
}

######### Code copied from https://get.pnpm.io/install.sh #########
# some minor modifications...

# From https://github.com/Homebrew/install/blob/master/install.sh
abort() {
  printf "%s\n" "$@"
  exit 1
}

# string formatters
if [ -t 1 ]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$1"
}

# End from https://github.com/Homebrew/install/blob/master/install.sh

download() {
  if command -v curl > /dev/null 2>&1; then
    curl -fsSL "$1"
  else
    wget -qO- "$1"
  fi
}

validate_url() {
  local url
  url="$1"
  
  if command -v curl > /dev/null 2>&1; then
    curl --output /dev/null --silent --show-error --location --head --fail "$url"
  else
    wget --spider --quiet "$url"
  fi
}

is_glibc_compatible() {
  getconf GNU_LIBC_VERSION >/dev/null 2>&1 || ldd --version >/dev/null 2>&1 || return 1
}

detect_platform() {
  local platform
  platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
  
  case "${platform}" in
    linux)
      if is_glibc_compatible; then
        platform="linux"
      else
        platform="linuxstatic"
      fi
    ;;
    darwin) platform="macos" ;;
    windows) platform="win" ;;
  esac
  
  printf '%s' "${platform}"
}

detect_arch() {
  local arch
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
  
  case "${arch}" in
    x86_64 | amd64) arch="x64" ;;
    armv*) arch="arm" ;;
    arm64 | aarch64) arch="arm64" ;;
  esac
  
  # `uname -m` in some cases mis-reports 32-bit OS as 64-bit, so double check
  if [ "${arch}" = "x64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=i686
    elif [ "${arch}" = "arm64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=arm
  fi
  
  case "$arch" in
    x64*) ;;
    arm64*) ;;
    *) return 1
  esac
  printf '%s' "${arch}"
}

get_latest_version() {
  # pulls current package.json and sets the "version" variable
  local version_json
  version_json="$(download "https://registry.npmjs.org/@pnpm/exe")" || abort "Download Error!"
  version="$(printf '%s' "${version_json}" | tr '{' '\n' | awk -F '"' '/latest/ { print $4 }')"
}

find_version() {
  # The first argument is the major version number
  local major_version=$1

  # Read the file and find the line
  resolved_major=$(grep "^$major_version\." "$HOME/.pvm/versions.txt" | grep "^[0-9\.-]*$" | tail -n 1)

  # Return the result
  echo "$resolved_major"
}

download_and_install_pnpm() {
  # requires "version" to be defined
  local platform arch version_json archive_url
  platform="$(detect_platform)"
  arch="$(detect_arch)" || abort "Sorry! pnpm currently only provides pre-built binaries for x86_64/arm64 architectures."

  version=$("$cmds_dir/resolve_version.sh" "$version")

  install_dir="$base_dir/$version"
  ensure_dir "$base_dir"

  # first validate that incoming version exists/has a url
  archive_url="https://github.com/pnpm/pnpm/releases/download/v${version}/pnpm-${platform}-${arch}"
  if [ "${platform}" = "win" ]; then
    archive_url="${archive_url}.exe"
  fi

  echo "Archive url: $archive_url"
  
  validate_url "$archive_url"  || abort "pnpm version '${version}' could not be found"

  # for now, always force-install:
  remove_dir "$install_dir"
  ensure_dir "$install_dir"
  
  tmp_dir="$(mktemp -d)" || abort "Tmpdir Error!"
  # note: tmp_dir cannot be local due to this trap:
  trap 'rm -rf "$tmp_dir"' EXIT INT TERM HUP
  
  ohai "Downloading pnpm binaries ${version}"
  if [ "$pvm_DEBUG" = "true" ]; then
    echo "Using temp dir $tmp_dir"
  fi
  # download the binary to the specified directory
  download "$archive_url" > "$tmp_dir/pnpm"  || return 1
  # allow binary execution:
  chmod +x "$tmp_dir/pnpm"
  # Copy the binary to the install directory
  mv "$tmp_dir/pnpm" "$install_dir"
  rm -r "$tmp_dir"
  if [ "$pvm_DEBUG" = "true" ]; then
    echo "Removed temp dir $tmp_dir"
    echo "Installed pnpm to $install_dir"
  fi
}

##################### End of copied code ####################

# Script starts here:
version=${1:-}

if [ -z "${version}" ]; then
  get_latest_version
  # ^ this also sets the "version" variable as a side-effect
fi
echo "Installing version $version"
download_and_install_pnpm
echo "Installed version $version"

# ensure default version exists:
if [[ ! -f $default_version_file ]]; then
  echo "No default version detected, setting $version as default."
  echo "$version" > "$default_version_file"
fi

# use the newly-installed version:
"$base_dir/cmds/use.sh" "$version"

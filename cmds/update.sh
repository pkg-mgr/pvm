#!/bin/bash

# Updates pvm to the latest version. Also updates pnpm package.json / remote version list.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/pkg-mgr/pvm/main/setup.sh | bash

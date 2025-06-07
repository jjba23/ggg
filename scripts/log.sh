#!/usr/bin/env bash

# Copyright © Josep Bigorra <jjbigorra@gmail.com>

# ggg is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# ggg is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with ggg. If not, see <https://www.gnu.org/licenses/>.

set -euo pipefail;

BOLD='\033[1m'
RED='\033[0;31m'
RESET='\033[0m'

get-timestamp() {
  date '+%Y-%m-%d %H:%M:%S%:z'
}

log-error() {
  if [ -z "$1" ]; then
    log-error "log-error was called without a message."
    return 1
  fi

  echo -e "${RED}[ERROR][$(get-timestamp)] $1${RESET}" >&2
}

log-info() {
  if [ -z "$1" ]; then
    log-error "log-info was called without a message."
    return 1
  fi
  
  echo -e "${BOLD}[INFO][$(get-timestamp)] $1${RESET}"
}

#!/bin/bash

set -e
set -o pipefail

function decrypt_file() {
    SOPS_GPG_EXEC={GPG_BINARY} {SOPS_BINARY_PATH} -d $1 --config {SOPS_CONFIG_FILE} > $2
}

# Hack: Define $HOME so sops can grab things from there if the user has set it up in that way
export HOME=$(realpath ~)
{DECRYPT_FILES}

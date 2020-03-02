#!/bin/bash

set -e
set -o pipefail

if ( [ "{SOPS_PROVIDER}" == "gcp_kms" ] && [ -z $GOOGLE_APPLICATION_CREDENTIALS ] ); then
  export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json
fi

function decrypt_file() {
    {SOPS_BINARY_PATH} -d $1 --config {SOPS_CONFIG_FILE} > $2
}

{DECRYPT_FILES}
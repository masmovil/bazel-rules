#!/bin/bash

set -e
set -o pipefail

echo $GOOGLE_APPLICATION_CREDENTIALS

if [ "{SOPS_PROVIDER}" == "gcp_kms" ] && [ -z $GOOGLE_APPLICATION_CREDENTIALS ]; then
    echo "Exporting GOOGLE_APPLICATION_CREDENTIALS env var"
    # Exports GOOGLE_APPLICATION_CREDENTIALS variable to use application-default credentials
    export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json
fi

if [ "{SOPS_PROVIDER}" == "gpg" ]; then
    # Exports GPG binary path to be used by sops
    export SOPS_GPG_EXEC={GPG_BINARY}
fi

function decrypt_file() {
    {SOPS_BINARY_PATH} -d $1 --config {SOPS_CONFIG_FILE} > $2
}

{DECRYPT_FILES}

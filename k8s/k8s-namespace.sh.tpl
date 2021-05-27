#!/bin/bash

set -e
set -o pipefail

function guess_runfiles() {
    if [ -d ${BASH_SOURCE[0]}.runfiles ]; then
        # Runfiles are adjacent to the current script.
        echo "$( cd ${BASH_SOURCE[0]}.runfiles && pwd )"
    else
        # The current script is within some other script's runfiles.
        mydir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        echo $mydir | sed -e 's|\(.*\.runfiles\)/.*|\1|'
    fi
}

RUNFILES="${PYTHON_RUNFILES:-$(guess_runfiles)}"
TEMP_FILES="$(mktemp -t 2>/dev/null || mktemp -t 'helm_release_files')"

function read_variables() {
    local file="${RUNFILES}/$1"
    local new_file="$(mktemp -t 2>/dev/null || mktemp -t 'helm_release_new')"
    echo "${new_file}" >> "${TEMP_FILES}"

    # Rewrite the file from Bazel for the form FOO=...
    # to a form suitable for sourcing into bash to expose
    # these variables as substitutions in the tag statements.
    sed -E "s/^([^ ]+) (.*)\$/export \\1='\\2'/g" < ${file} > ${new_file}
    source ${new_file}
}

%{stamp_statements}

kubectl --context {KUBECONTEXT} create ns {NAMESPACE_NAME} 2>/dev/null || true

if [ "{GCP_SA}" != "" ]; then

    gcloud --project={GCP_GKE_PROJECT} iam service-accounts add-iam-policy-binding \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:{WORKLOAD_IDENTITY_NAMESPACE}[{NAMESPACE_NAME}/{KUBERNETES_SA}]" \
        projects/{GCP_SA_PROJECT}/serviceAccounts/{GCP_SA}

    kubectl --context {KUBECONTEXT} -n {NAMESPACE_NAME} annotate sa {KUBERNETES_SA} iam.gke.io/gcp-service-account={GCP_SA} --overwrite


fi

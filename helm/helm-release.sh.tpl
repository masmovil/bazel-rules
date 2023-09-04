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

FORCE_HELM_VERSION={FORCE_HELM_VERSION}

CREATE_NAMESPACE=""
FORCE=""
HELM_OPTIONS=""
TIMEOUT=""
WAIT=""

if [ "{FORCE}" != "" ]; then
    FORCE="--force"
fi

if [ "{TIMEOUT}" != "" ]; then
    TIMEOUT="--timeout {TIMEOUT}"
fi

if [ "{KUBERNETES_CONTEXT}" != "" ]; then
    HELM_OPTIONS="--kube-context {KUBERNETES_CONTEXT}"
fi

if [ "{CREATE_NAMESPACE}" != "" ]; then
    CREATE_NAMESPACE="--create-namespace"
fi

if [ "{WAIT}" != "" ]; then
    WAIT="--wait"
fi

# use helm 3 to make the release
echo "Using helm v3 to deploy the {RELEASE_NAME} release"

{KUBECTL_PATH} create namespace {NAMESPACE} 2> /dev/null || true

echo "{HELM3_PATH} upgrade {RELEASE_NAME} {CHART_PATH} --install $HELM_OPTIONS --namespace {NAMESPACE} $CREATE_NAMESPACE $TIMEOUT $FORCE $WAIT {VALUES_YAML}"
{HELM3_PATH} upgrade {RELEASE_NAME} {CHART_PATH} --install $HELM_OPTIONS --namespace {NAMESPACE} $CREATE_NAMESPACE $TIMEOUT $FORCE $WAIT {VALUES_YAML}

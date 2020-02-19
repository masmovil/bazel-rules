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

TILLER_PODS=$({KUBECTL_PATH} get pods -n {TILLER_NAMESPACE} | grep tiller | wc -l)


if [ $TILLER_PODS -ge 1]; then
    # tiller pods were found, we will use helm 2 to make the release
    echo "Using helm v2 to deploy the {RELEASE_NAME} release"

    {HELM_PATH} init -c

    if [ "{SECRETS_YAML}" != "" ]; then
        {HELM_PATH} secrets upgrade --install --tiller-namespace {TILLER_NAMESPACE} --namespace {NAMESPACE} {VALUES_YAML} {SECRETS_YAML} {RELEASE_NAME} {CHART_PATH}
    else
        {HELM_PATH} upgrade --install --tiller-namespace {TILLER_NAMESPACE} --namespace {NAMESPACE} {VALUES_YAML} {RELEASE_NAME} {CHART_PATH}
    fi
else
    # tiller pods were not found, we will use helm 3 to make the release
    echo "Using helm v3 to deploy the {RELEASE_NAME} release"

    if [ "{SECRETS_YAML}" != "" ]; then
        {HELM3_PATH} secrets upgrade {RELEASE_NAME} {CHART_PATH} --install --namespace {NAMESPACE} {VALUES_YAML} {SECRETS_YAML}
    else
        {HELM3_PATH} upgrade {RELEASE_NAME} {CHART_PATH} --install --namespace {NAMESPACE} {VALUES_YAML}
    fi
fi

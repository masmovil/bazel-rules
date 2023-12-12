#!/bin/bash

set -e
set -o pipefail

TEMP_FILES="$(mktemp -t 2>/dev/null || mktemp -t 'helm_release_files')"

function read_variables() {
    local file="$1"
    local new_file="$(mktemp -t 2>/dev/null || mktemp -t 'helm_release_new')"
    echo "${new_file}" >> "${TEMP_FILES}"

    # Rewrite the file from Bazel for the form FOO=...
    # to a form suitable for sourcing into bash to expose
    # these variables as substitutions in the tag statements.
    sed -E "s/^([^ ]+) (.*)\$/export \\1='\\2'/g" < ${file} > ${new_file}
    source ${new_file}
}

%{stamp_statements}

{HELM_PATH} package {CHART_PATH} --dependency-update --destination {PACKAGE_OUTPUT_PATH} --app-version {APP_VERSION} --version {HELM_CHART_VERSION} 1>>/dev/null

mv {PACKAGE_OUTPUT_PATH}/{HELM_CHART_NAME}-{HELM_CHART_VERSION}.tgz {PACKAGE_OUTPUT_PATH}/{HELM_CHART_NAME}.tgz

rm -rf {CHART_PATH}

echo "Successfully packaged chart and saved it to: {PACKAGE_OUTPUT_PATH}/{HELM_CHART_NAME}.tgz"

#!/bin/bash

set -e
set -o pipefail

function read_stamp_variables() {
    local file="$1"
    local new_file="$(mktemp -t 2>/dev/null || mktemp -t 'helm_stamp_new')"

    sed -E "s/^([^ ]+) (.*)\$/export \\1='\\2'/g" < ${file} > ${new_file}
    source ${new_file}
}

if [ "{stamp}" == "true" ]; then
    %{stamp_statements}
fi;

if [ -f "{values}" ]; then
    {yq} --from-file {expression} {values} > {out}
else
    TEMP_VALUES="$(mktemp -t 2>/dev/null || mktemp -t 'helm_empty_values')"
    {yq} --from-file {expression} ${TEMP_VALUES} > {out}
fi;

export IMAGE_DIGEST={image_digest_expr}

if [ ! -z "${IMAGE_DIGEST}" ]; then
    {yq} -i '{image_tag_path} = strenv(IMAGE_DIGEST)' {out};
fi;

export IMAGE_REPO={image_repo_expr}

if [ ! -z "${IMAGE_REPO}" ]; then
    {yq} -i '{image_repo_path} = strenv(IMAGE_REPO)' {out};
fi;

#!/bin/bash

set -e
set -o pipefail

DIGEST_PATH={DIGEST_PATH}
IMAGE_REPOSITORY={IMAGE_REPOSITORY}

if [ -z $DIGEST_PATH ]; then
    {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_TAG_YAML_PATH} {IMAGE_TAG}
    echo "Packaged image tag: {IMAGE_TAG}"
else
    # extracts the digest sha and removes 'sha256' text from it
    DIGEST=$(cat {DIGEST_PATH})
    IFS=':' read -ra digest_split <<< "$DIGEST"
    DIGEST_SHA=${digest_split[1]}
    {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_TAG_YAML_PATH} $DIGEST_SHA
    echo "Packaged image tag: "$DIGEST_SHA
fi

# if the tag is a digest add @sha256 as suffix to the image.repository
if [ -n $DIGEST_PATH ] && [ "$DIGEST_PATH" != "" ]; then
    REPO_SUFIX="@sha256"
    REPO_URL=$({YQ_PATH} r {CHART_VALUES_PATH} {VALUES_REPO_YAML_PATH})
fi

if [ -n $IMAGE_REPOSITORY ] && [ "$IMAGE_REPOSITORY" != "" ]; then
    REPO_URL="{IMAGE_REPOSITORY}"
fi

# appends suffix if REPO_URL does not already contains it
if ([ -n $REPO_URL ] || [ -n $REPO_SUFIX ]) && ([[ $REPO_URL != *"$REPO_SUFIX" ]] || [[ -z "$REPO_SUFIX" ]]); then
    {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_REPO_YAML_PATH} ${REPO_URL}${REPO_SUFIX}
fi

# pwd
helm init --client-only > /dev/null
# Remove local repo to increase reproducibility and remove errors
helm repo remove local > /dev/null
helm package {CHART_PATH} --dependency-update --destination {PACKAGE_OUTPUT_PATH} --app-version {HELM_CHART_VERSION} --version {HELM_CHART_VERSION} > /dev/null
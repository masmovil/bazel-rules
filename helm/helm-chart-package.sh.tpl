#!/bin/bash

set -e
set -o pipefail

DIGEST_PATH={DIGEST_PATH}
IMAGE_REPOSITORY={IMAGE_REPOSITORY}
IMAGE_TAG={IMAGE_TAG}

chmod 777 {CHART_VALUES_PATH}

# Application docker image is not provided by other docker bazel rule
if  [ -z $DIGEST_PATH ]; then

    # Image repository is provided as a static value
    if [ "$IMAGE_REPOSITORY" != "" ] && [ -n $IMAGE_REPOSITORY ]; then
        {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_REPO_YAML_PATH} $IMAGE_REPOSITORY
        echo "Replaced image repository in chart values.yaml with: $IMAGE_REPOSITORY"
    fi

    # Image tag is provided as a static value
    if [ "$IMAGE_TAG" != "" ] && [ -n $IMAGE_TAG ]; then
        {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_TAG_YAML_PATH} $IMAGE_TAG
        echo "Replaced image tag in chart values.yaml with: $IMAGE_TAG"
    fi

fi

# Application docker image is provided by other docker bazel rule
if [ -n $DIGEST_PATH ] && [ "$DIGEST_PATH" != "" ]; then
    # extracts the digest sha and removes 'sha256' text from it
    DIGEST=$(cat {DIGEST_PATH})
    IFS=':' read -ra digest_split <<< "$DIGEST"
    DIGEST_SHA=${digest_split[1]}

    {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_TAG_YAML_PATH} $DIGEST_SHA

    echo "Replaced image tag in chart values.yaml with: $DIGEST_SHA"

    REPO_SUFIX="@sha256"

    if [ -n $IMAGE_REPOSITORY ] && [ "$IMAGE_REPOSITORY" != "" ]; then
        REPO_URL="{IMAGE_REPOSITORY}"
    else
        # if image_repository attr is not provided, extract it from values.yaml
        REPO_URL=$({YQ_PATH} r {CHART_VALUES_PATH} {VALUES_REPO_YAML_PATH})
    fi

    # appends @sha256 suffix to image repo url value if the repository value does not already contains it
    if ([ -n $REPO_URL ] || [ -n $REPO_SUFIX ]) && ([[ $REPO_URL != *"$REPO_SUFIX" ]] || [[ -z "$REPO_SUFIX" ]]); then
        {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_REPO_YAML_PATH} ${REPO_URL}${REPO_SUFIX}
    fi
fi

{HELM_PATH} init --client-only > /dev/null

# Remove local repo to increase reproducibility and remove errors
if [ "$(helm repo list |grep local)" != "" ]; then
    echo "Remove local helm repo"
    helm repo remove local 2> /dev/null || true
fi

{HELM_PATH} package {CHART_PATH} --dependency-update --destination {PACKAGE_OUTPUT_PATH} --app-version {HELM_CHART_VERSION} --version {HELM_CHART_VERSION}

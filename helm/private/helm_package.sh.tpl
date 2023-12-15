#!/bin/bash

set -e
set -o pipefail

{HELM_PATH} package {CHART_PATH} --dependency-update --destination {PACKAGE_OUTPUT_PATH} --app-version {APP_VERSION} --version {HELM_CHART_VERSION} 2>>/dev/null

mv {PACKAGE_OUTPUT_PATH}/{HELM_CHART_NAME}-{HELM_CHART_VERSION}.tgz {PACKAGE_OUTPUT_PATH}/{HELM_CHART_NAME}.tgz

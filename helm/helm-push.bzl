load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _helm_push_impl(ctx):
    """Push a helm chart to a helm repository
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """

    chart = ctx.file.chart

    repo_url = get_make_value_or_default(ctx, ctx.attr.repository_url)
    repo_name = get_make_value_or_default(ctx, ctx.attr.repository_name)

    inputs = []


    if ctx.attr.repo_type == "museum" or ctx.attr.repo_type == "nexus":

        # get chart museum basic auth credentials
        user = get_make_value_or_default(ctx, ctx.attr.repository_username)
        user_pass = get_make_value_or_default(ctx, ctx.attr.repository_password)

        if not repo_url.endswith("/"):
            repo_url += "/"
        if ctx.attr.repo_type == "museum":
            repo_url += "api/charts"
            curl_arg = "--data-binary"
            chart_path = "@" + chart.short_path
        elif ctx.attr.repo_type == "nexus":
            curl_arg = "--upload-file"
            chart_path = chart.short_path

        # Generates the exec bash file with the provided substitutions
        exec_file = write_sh(
            ctx,
            "curl_bash",
            """
                HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" {CURL_ARG} "{CHART_PATH}" -u {USERNAME}:{PASSWORD} {REPOSITORY_URL})
                echo "http post response code: "$HTTP_CODE

                if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "409" ]; then
                echo "exit 0"
                exit 0
                else
                echo "exit 1"
                exit 1
                fi
            """,
            {
                "{CHART_PATH}": chart_path,
                "{USERNAME}": user,
                "{PASSWORD}": user_pass,
                "{REPOSITORY_URL}": repo_url,
                "{CURL_ARG}": curl_arg,
            }
        )

    if ctx.attr.repo_type == "gcp_artifact_registry":
        chart_path = chart.short_path
        helm_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.tool
        gcloud_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/gcloud:toolchain_type"].gcloudinfo.gcloud
        yq_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/yq:toolchain_type"].yqinfo.tool.files.to_list()[0]

        inputs = [helm_binary, gcloud_binary, yq_binary]
        #sets up values for the Artifact Registry API call
        #splits the repo_name as passed to this rule ("mm-provision-dev/charts"), to extract the GCP project - index 0 and the Artifact Registry repo name - index 1
        gcp_project = repo_name.split("/")[0]
        repo_name_inside_gcp_project = repo_name.split("/")[1]
        #gets the first part of the repo URL which is always the location (example: europe-docker.pkg.dev, europe in this case)
        gcp_location = repo_url.split("-")[0]
        allow_overwrite = str(ctx.attr.allow_overwrite)

        exec_file = write_sh(
        ctx,
        "helm_oci_push_gcp_artifact_registry_bash",
        """
            GCP_ACCESS_TOKEN=$({GCLOUD_BINARY} auth application-default print-access-token)

            # Create temp random directory
            WORK_DIR={CHART_PATH}_workdir
            mkdir -p $WORK_DIR
            # Extract into a temp directory


            if [[ "$OSTYPE" == "darwin"* ]]; then
                tar xf {CHART_PATH} -C $WORK_DIR/ '*/Chart.yaml'
            else
                tar xf {CHART_PATH} -C $WORK_DIR/ --wildcards '*/Chart.yaml'
            fi

            # Find main Chart.yaml
            CHART_YAML=$(ls $WORK_DIR/*/Chart.yaml)
            if [ "$CHART_YAML" = "" ]; then
                echo "❌ !!Error!! Can't detect and read Chart.yaml file. This must rathar be a problem with the rule or the environment."
                exit 1
            fi

            # Read package name
            PACKAGE_NAME=$({YQ_BINARY} r $CHART_YAML name)
            YQ_EXIT_CODE=$?
            if [ $YQ_EXIT_CODE != 0 ]; then
                echo "Could not detect package name. Not pushing ... Exiting with code: $YQ_EXIT_CODE (from YQ)"
                exit $YQ_EXIT_CODE
            fi

            # Read package version
            DETECTED_PACKAGE_VERSION=$({YQ_BINARY} r $CHART_YAML version)
            YQ_EXIT_CODE=$?
            if [ $YQ_EXIT_CODE != 0 ]; then
                echo "Could not detect package version. Not pushing ... Exiting with code: $YQ_EXIT_CODE (from YQ)"
                exit $YQ_EXIT_CODE
            fi

            echo "Checking against Artifact Registry..."
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer $GCP_ACCESS_TOKEN" https://artifactregistry.googleapis.com/v1beta2/projects/{GCP_PROJECT}/locations/{GCP_LOCATION}/repositories/{REPO_NAME_INSIDE_GCP_PROJECT}/packages/$PACKAGE_NAME/tags/$DETECTED_PACKAGE_VERSION)
            echo "Response code for $PACKAGE_NAME:$DETECTED_PACKAGE_VERSION : $HTTP_CODE , allow_overwite is set to {ALLOW_OVERWRITE}"
            if [ "$HTTP_CODE" = "200" ] && [ "{ALLOW_OVERWRITE}" = "False" ]; then
            exit 0
            fi

            echo "$GCP_ACCESS_TOKEN" | {HELM_BINARY} registry login -u oauth2accesstoken --password-stdin {REPOSITORY_URL}

            {HELM_BINARY} push {CHART_PATH} oci://{REPOSITORY_URL}/{REPOSITORY_NAME}

            rm -rf $WORK_DIR
        """,
        {
            "{CHART_PATH}": chart_path,
            "{REPOSITORY_URL}": repo_url,
            "{REPOSITORY_NAME}": repo_name,
            "{HELM_BINARY}": helm_binary.path,
            "{GCLOUD_BINARY}": gcloud_binary.path,
            "{YQ_BINARY}": yq_binary.path,
            "{GCP_PROJECT}": gcp_project,
            "{GCP_LOCATION}": gcp_location,
            "{REPO_NAME_INSIDE_GCP_PROJECT}": repo_name_inside_gcp_project,
            "{ALLOW_OVERWRITE}": allow_overwrite,
        }
        )


    runfiles = ctx.runfiles(files = [chart]  + inputs)

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_push = rule(
    implementation = _helm_push_impl,
    attrs = {
      "chart": attr.label(allow_single_file = True, mandatory = True),
      "repository_name": attr.string(mandatory = True),
      "repository_url": attr.string(mandatory = True),
      "repository_username": attr.string(mandatory = False),
      "repository_password": attr.string(mandatory = False),
      "repo_type": attr.string(
        values = ["museum", "nexus", "gcp_artifact_registry"],
        default = "museum",
        doc = """
        Repository type to deploy to. Now supports:
        * Helm Chart Museum: https://github.com/helm/chartmuseum
        * Sonatype Nexus Helm: https://help.sonatype.com/repomanager3/formats/helm-repositories
        * GCP Artiract registry (OCI): https://cloud.google.com/artifact-registry/docs/helm/manage-charts
        """,
      ),
      "allow_overwrite": attr.bool(mandatory = False, default = False),
    },
    doc = "Push helm chart to a helm repository",
    toolchains = [
        "@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type",
        "@com_github_masmovil_bazel_rules//toolchains/gcloud:toolchain_type",
        "@com_github_masmovil_bazel_rules//toolchains/yq:toolchain_type",
    ],
    executable = True,
)

load(":helm_chart_providers.bzl", "ChartInfo")

_DOC = """
    Publish a helm chart produced by `helm_chart` rule to a remote registry.
"""

def _helm_push_impl(ctx):
    chart = ctx.file.chart
    chart_name = ctx.attr.chart[ChartInfo].chart_name

    repo_url = ctx.attr.repository_url

    is_oci = repo_url.startswith('oci://')

    helm_bin = ctx.toolchains["@masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.bin

    script_template = ctx.actions.declare_file(ctx.attr.name + "_run_script.tpl")

    ctx.actions.write(
        output = script_template,
        content = """
IS_OCI="{IS_OCI}"

if [ "$IS_OCI" == "True" ]; then
    {HELM_BINARY} push {CHART_PATH} {REMOTE}/{CHART_NAME}
else
    EXTRA_ARGS=""

    if [ "$HELM_USER" != "" ] && [ "$HELM_PASSWORD" != "" ]; then
        EXTRA_ARGS="-u $HELM_USER:$HELM_PASSWORD"
    fi

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" --data-binary "@{CHART_PATH}" $EXTRA_ARGS {REMOTE})

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "409" ]; then
        echo "Success - http post response code: "$HTTP_CODE
    exit 0
    else
        echo "Error - http post response code: "$HTTP_CODE
        exit 1

    fi
fi
""",)

    runfile_helm_push_script = ctx.actions.declare_file(ctx.attr.name + "_run_script")

    inputs = [helm_bin, chart]

    ctx.actions.expand_template(
        template = script_template,
        output = runfile_helm_push_script,
        is_executable = True,
        substitutions = {
            "{IS_OCI}": str(is_oci),
            # We use short_path because it's a runfile
            "{CHART_PATH}": chart.short_path,
            "{CHART_NAME}": chart_name,
            "{HELM_BINARY}": helm_bin.path,
            "{REMOTE}": repo_url,
        },
    )

    runfiles = ctx.runfiles(files = inputs)

    return [DefaultInfo(
      executable = runfile_helm_push_script,
      runfiles = runfiles,
    )]

helm_push = rule(
    implementation = _helm_push_impl,
    attrs = {
      "chart": attr.label(allow_single_file = True, mandatory = True, providers = [ChartInfo], doc = """
        The packaged chart archive to be published. It can be a reference to a `helm_chart` rule or a reference to a helm archived file"""
        ),
      "repository_url": attr.string(mandatory = True, doc = "The remote url of the registry. Avoid adding the helm chart name in the url."),
    },
    doc = _DOC,
    toolchains = [
        "@masmovil_bazel_rules//toolchains/helm:toolchain_type",
        "@aspect_bazel_lib//lib:yq_toolchain_type",
    ],
    executable = True,
)

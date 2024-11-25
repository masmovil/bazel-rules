load("@bazel_skylib//rules:write_file.bzl", "write_file")
load(":helm_chart_providers.bzl", "ChartInfo")

_DOC = """Test rule to verify that a helm chart is well-formed.

    To load the rule use:
    ```starlark
    load("//helm:defs.bzl", "helm_lint_test")
    ```

    It uses `helm lint` command to perform the linting.
"""

_ATTRS = {
    "chart": attr.label(mandatory = True, allow_single_file = True, providers = [ChartInfo], doc="The chart to lint. It could be either a reference to a `helm_chart` rule that produces an archived chart as a default output or a reference to an archived chart."),
}

def _helm_lint_test_impl(ctx):
    chart_targz = ""

    chart_targz = ctx.file.chart

    helm_bin = ctx.toolchains["@masorange_rules_helm//helm:helm_toolchain_type"].helminfo.bin

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = """
          {helm} lint {chart}
        """.format(helm=helm_bin.path, chart=chart_targz.short_path),
    )

    return [
        DefaultInfo(runfiles = ctx.runfiles(files = [helm_bin, chart_targz]))
    ]

helm_lint_test = rule(
    implementation = _helm_lint_test_impl,
    attrs = _ATTRS,
    doc = _DOC,
    toolchains = [
        "@masorange_rules_helm//helm:helm_toolchain_type",
    ],
    test = True,
)

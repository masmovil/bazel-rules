load("//helpers:helpers.bzl", "get_make_value_or_default", "write_sh")
load("@aspect_bazel_lib//lib/private:copy_to_bin.bzl", "copy_files_to_bin_actions")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:shell.bzl", "shell")

ChartInfo = provider(fields = [
    "targz",
    "chart_name",
    "chart_version",
    "chart_srcs",
])

def _helm_chart_providers_impl(ctx):
    """Defines a helm chart (directory containing a Chart.yaml).
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """
    targz_deps = depset(ctx.files.chart_targz)

    return [
        DefaultInfo(
            files = targz_deps
        ),
        ChartInfo(
            targz = targz_deps,
            chart_srcs = ctx.files.chart_bin_srcs,
            chart_name = ctx.attr.chart_name,
            chart_version = ctx.attr.chart_version,
        ),
    ]

helm_chart_providers = rule(
    implementation = _helm_chart_providers_impl,
    attrs = {
        "chart_name": attr.string(mandatory = True),
        "chart_targz": attr.label(allow_single_file = True, mandatory = True,),
        "chart_bin_srcs": attr.label(allow_files = True, mandatory = True,),
        "chart_version": attr.string(mandatory = False,),
    },
    doc = "",
)

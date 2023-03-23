# Copyright Jay Conrod. All rights reserved.

# This file is part of rules_go_simple. Use of this source code is governed by
# the 3-clause BSD license that can be found in the LICENSE.txt file.

"""Workspace rule for declaring external helm chart dependencies."""

load("@bazel_skylib//lib:paths.bzl", "paths")


def _helm_chart_dependency_impl(repository_ctx):
    """Declares external helm chart that helm_chart rule depends on.
    This function should be loaded and called from WORKSPACE of any project
    that uses helm_chart.
    """
    chart_name = repository_ctx.attr.chart_name
    chart_version = repository_ctx.attr.chart_version
    chart_file = chart_name + "-" + chart_version + ".tgz"
    name = repository_ctx.name
    chart_dep_url = ""
    chart_dep_digest = ""
    yq_binary = ""

    repository_ctx.report_progress("downloading repo index file")

    repository_ctx.download(
        url = paths.join(repository_ctx.attr.repo_url, "index.yaml"),
        output = name + "-index.yaml"
    )

    repository_ctx.report_progress("downloading yq binary")

    if repository_ctx.os.name == "linux":
        repository_ctx.download(
            url = "https://github.com/mikefarah/yq/releases/download/v4.13.5/yq_linux_amd64",
            output = "yq",
            executable = True,
            # sha256 = "06732685917646c0bbba8cc17386cd2a39b214ad3cd128fb4b8b410ed069101c",
        )

    if repository_ctx.os.name == "mac os x":
        repository_ctx.download(
            url = "https://github.com/mikefarah/yq/releases/download/v4.13.5/yq_darwin_amd64",
            output = "yq",
            executable = True,
            sha256 = "c261173d53636f4ab28bec6388a24eb554a1cccec5daf6988d882b2b969952ee",
        )

    if repository_ctx.os.name == "windows":
        repository_ctx.download(
            url = "https://github.com/mikefarah/yq/releases/download/v4.13.5/yq_windows_amd64.exe",
            output = "yq",
            executable = True,
            # sha256 = "754c6e6a7ef92b00ef73b8b0bb1d76d651e04d26aa6c6625e272201afa889f8b",
        )

    result = repository_ctx.execute([
        repository_ctx.path("yq"),
        "eval",
        "-o=json",
        name + "-index.yaml"
    ])

    if result.return_code:
      fail("Failed to parse helm repository index.yaml to json %s" % result.stderr)

    decodedJson = json.decode(result.stdout)

    entries = decodedJson.get("entries")
    chart_versions = entries.get(chart_name)

    for chart in chart_versions:
        if chart.get("version") == chart_version:
            chart_dep_url = chart.get("urls")[0]
            chart_dep_digest = chart.get("digest")
            break

    if chart_dep_url.find("http://") == -1 and chart_dep_url.find("https://") == -1:
        chart_dep_url = paths.join(repository_ctx.attr.repo_url, chart_dep_url)

    repository_ctx.report_progress("downloading chart")

    repository_ctx.download_and_extract(
        url = chart_dep_url,
        sha256 = chart_dep_digest,
        stripPrefix = chart_name,
        output = chart_name
    )

    repository_ctx.report_progress("generating build file")

    substitutions = {
        "{CHART_NAME}": repository_ctx.attr.chart_name,
        "{CHART_VERSION}": repository_ctx.attr.chart_version,
    }

    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.attr._build_tpl,
        substitutions = substitutions,
    )

helm_chart_dependency = repository_rule(
    implementation = _helm_chart_dependency_impl,
    attrs = {
        "repo_url": attr.string(
            mandatory = True,
            doc = "Helm repository URL from where the Helm chart can be downloaded",
        ),
        "chart_name": attr.string(
            mandatory = True,
            doc = "Name of the helm chart",
        ),
        "chart_version": attr.string(
            mandatory = True,
            doc = "Version of the helm chart",
        ),
        "sha256": attr.string(
            mandatory = False,
            doc = "Sha of the helm chart",
        ),
        "_build_tpl": attr.label(
            default = ":BUILD.chart_dep.tpl",
        ),
    },
    doc = "Downloads a helm chart from a helm repository",
)

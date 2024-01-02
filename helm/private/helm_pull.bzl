load("@bazel_skylib//lib:paths.bzl", "paths")

pull_attrs = {
    "chart_name": attr.string(mandatory = True),
    "repo_url": attr.string(mandatory = True),
    "repo_name": attr.string(mandatory = False),
    # TODO: extract latest version from repo index and mark version as an optional attr
    "version": attr.string(mandatory = True),
    "sha256": attr.string(mandatory = False, doc = "Sha of the helm chart"),
    "repository_config": attr.label(allow_single_file = True, mandatory = False),
}

def _helm_pull_impl(rctx):
    name = rctx.attr.name
    chart_name = rctx.attr.chart_name
    version = rctx.attr.version

    result = rctx.execute([
        "helm",
        "version"
    ])

    if result.return_code != 0:
        fail("no helm binary found")

    args = ["helm", "pull"]

    if rctx.attr.repository_config and rctx.attr.repo_name:
        args += ["%s/%s" % (rctx.attr.repo_name, rctx.attr.chart_name), "--version", rctx.attr.version]
    else:
        exact_url = "%s-%s.tgz" % (paths.join(rctx.attr.repo_url, chart_name), version)
        args += [exact_url]

    if rctx.attr.repository_config:
        args += ["--repository-config", rctx.file.repository_config.path]

    username = rctx.os.environ.get("HELM_USER", "")
    password = rctx.os.environ.get("HELM_PASSWORD", "")

    if username and password:
        args += ["--username", username, "--password", password]

    args += ["--untar"]

    result = rctx.execute(args)

    if result.return_code != 0:
        fail("unable to download helm chart %s with code %s - " % (chart_name, result.return_code) + result.stderr)

    rctx.file(
        "BUILD.bazel",
        """
package(default_visibility = ["//visibility:public"])

load("@masmovil_bazel_rules//helm:defs.bzl", "helm_chart")

helm_chart(
    name = "chart",
    chart_name = "{name}",
    srcs = glob(["{name}/**"]),
    version = "{version}",
    visibility = ["//visibility:public"],
)
        """.format(
            name=chart_name,
            version=version,
        ),
    )

helm_pull = repository_rule(
    implementation = _helm_pull_impl,
    attrs = pull_attrs,
    doc = "Pull helm charts from external helm repositories",
)

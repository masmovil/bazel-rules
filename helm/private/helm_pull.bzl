load("@bazel_skylib//lib:paths.bzl", "paths")

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

    args = ["helm", "pull", paths.join(rctx.attr.url, chart_name), "--version", version, "--untar"]

    result = rctx.execute(args)

    if result.return_code != 0:
        print("unable to download helm chart %s with code %s" % (chart_name, result.return_code))
        fail(result.stderr)

    debug = rctx.execute(["tree", "."])

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

    debug2 = rctx.execute(["cat", "BUILD.bazel"])

helm_pull = repository_rule(
    implementation = _helm_pull_impl,
    attrs = {
        "chart_name": attr.string(mandatory = True),
        "url": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = False, doc = "Sha of the helm chart"),
    },
    doc = "Pull helm charts from external helm repositories",
)

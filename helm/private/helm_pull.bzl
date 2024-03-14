load("@bazel_skylib//lib:paths.bzl", "paths")

_DOC = """
    Repository rule to download a `helm_chart` from a remote registry.

    To load the rule use:
    ```starlark
    load("//helm:defs.bzl", "helm_pull")
    ```

    It uses `helm` binary to download the chart, so `helm` has to be available in the PATH of the host machine where bazel is running.

    Default credentials on the host machine are used to authenticate against the remote registry.
    To use basic auth you must provide the basic credentials through env variables: `HELM_USER` and `HELM_PASSWORD`.

    OCI registries are supported.

    The downloaded chart is defined using the `helm_chart` rule and it's available as `:chart` target inside the repo name.

    ```starlark
    # WORKSPACE or extensions.bzl/MODULE.bazel
    load("//helm:defs.bzl", "helm_pull")

    helm_pull(
        name = "example_helm_chart",
        chart_name = "example",
        repo_url = "oci://docker.pkg.dev/project/helm-charts",
        version = "1.0.0",
    )
    ```

    It can be later referenced in a BUILD file in `helm_chart` dep:

    ```starlark
    helm_chart(
        ...
        deps = [
            "@example_helm_chart//:chart",
        ]
    )
    ```
"""

pull_attrs = {
    "chart_name": attr.string(mandatory = True, doc="The name of the helm_chart to download. It will be appendend at the end of the repository url."),
    "repo_url": attr.string(mandatory = True, doc="The url where the chart is located. You have to omit the chart name from the url."),
    "repo_name": attr.string(mandatory = False, doc="The name of the repository. This is only useful if you provide a `repository_config` file and you want the repo url to be located within the repo config."),
    # TODO: extract latest version from repo index and mark version as an optional attr
    "version": attr.string(mandatory = True, doc="The version of the chart to download."),
    "repository_config": attr.label(allow_single_file = True, mandatory = False, doc="The repository config file."),
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

    # if rctx.attr.repository_config and rctx.attr.repo_name:
    args += ["%s/%s" % (rctx.attr.repo_name, rctx.attr.chart_name), "--version", rctx.attr.version]
    # else:
    #    exact_url = "%s-%s.tgz" % (paths.join(rctx.attr.repo_url, chart_name), version)
    #    args += [exact_url]

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
    doc = _DOC,
)

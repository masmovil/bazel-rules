load(":chart_srcs.bzl", "chart_srcs")
load(":helm_lint_test.bzl", "helm_lint_test")
load(":helm_chart_providers.bzl", "helm_chart_providers")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@rules_pkg//pkg:mappings.bzl", "pkg_filegroup", "pkg_files", "strip_prefix")

def helm_chart(name, chart_name, **kwargs):
    """Bazel macro function to package a helm chart in to a targz archive file.

    The macro is intended to be used as the public API for packaging a chart.

    It also defines a %name%_lint test target to be able to test that your chart is well-formed (using `helm lint`).

    To make the output reproducible this macro does not use `helm package` to package the chart into a versioned chart archive file.
    It uses `pkg_tar` bazel rule instead to create the archive file. Check this to find more info about:
    - https://github.com/masmovil/bazel-rules/issues/55
    - https://github.com/helm/helm/issues/3612#issuecomment-525340295

    The args are the same that the `chart_srcs` rule, check [chart_srcs](#chart_srcs).

    This macro exports some providers to share info about charts between rules. Check [helm_chart providers](#providers).

    Args:

    """

    helm_pkg_target = "%s_package" % name
    helm_pkg_out_strip_target = "%s_src_helm_files" % name
    tar_target = "%s_tar" % name

    chart_version = kwargs.get("version") or kwargs.get("helm_chart_version")

    chart_srcs(
        name = helm_pkg_target,
        chart_name = chart_name,
        **kwargs,
    )

    pkg_files(
        name = helm_pkg_out_strip_target,
        srcs = [helm_pkg_target],
        strip_prefix = strip_prefix.from_pkg(),
    )

    pkg_tar(
        name = tar_target,
        out = chart_name + ".tgz",
        extension = "tgz",
        srcs = [helm_pkg_out_strip_target],
    )

    helm_chart_providers(
        name = name,
        chart_name = chart_name,
        chart_targz = tar_target,
        chart_version = chart_version,
        chart_bin_srcs = helm_pkg_target,
    )

    helm_lint_test(
        name = "%s_lint" % name,
        chart = name,
    )

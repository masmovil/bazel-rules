load(":helm_package.bzl", "helm_package")
load(":helm_lint_test.bzl", "helm_lint_test")
load(":helm_chart_providers.bzl", "helm_chart_providers")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@rules_pkg//pkg:mappings.bzl", "pkg_filegroup", "pkg_files", "strip_prefix")

def helm_chart(name, chart_name, **kwargs):
    helm_pkg_target = "%s_package" % name
    helm_pkg_out_strip_target = "%s_src_helm_files" % name
    deps_rule_target = "%s_charts_deps" % name
    tar_target = "%s_tar" % name

    chart_version = kwargs.get("version") or kwargs.get("helm_chart_version")

    helm_package(
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

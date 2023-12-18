load(":helm_package.bzl", "helm_package")

load("@rules_pkg//pkg:tar.bzl", "pkg_tar")
load("@rules_pkg//pkg:mappings.bzl", "pkg_filegroup", "pkg_files", "strip_prefix")

def helm_chart(name, chart_name, **kwargs):
    helm_pkg_rule_name = name + "_package"

    helm_package(
        name = helm_pkg_rule_name,
        chart_name = chart_name,
        **kwargs,
    )

    pkg_files(
        name = name + "_src_helm_files",
        srcs = [":" + helm_pkg_rule_name],
        strip_prefix = strip_prefix.from_pkg(),
    )

    pkg_tar(
        name = name,
        out = chart_name + ".tgz",
        extension = "tgz",
        srcs = [":" + name + "_src_helm_files"],
    )

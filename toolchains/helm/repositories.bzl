load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

def _helm_toolchain_configure_impl(repository_ctx):
    environ = repository_ctx.os.environ
    helm_version = repository_ctx.attr.helm_version

    repository_ctx.template(
        "BUILD.bazel",
        Label("@com_github_masmovil_bazel_rules//toolchains/helm:BUILD.tpl"),
        {
            "%{HOME}": "%s" % environ["HOME"],
            "%{VERSION}": helm_version,
        },
        False,
    )

helm_toolchain_configure = repository_rule(
    implementation = _helm_toolchain_configure_impl,
    attrs = {
        "helm_version": attr.string(
            mandatory = True,
            doc = "Helm version to configure"
        )
    },
    environ = [
        "HOME"
    ]
)

def helm_configure(version, linux_amd64_sha, darwin_amd64_sha, darwin_arm64_sha,  windows_amd64_sha):
    helm_toolchain_configure(
        name = "mm_helm_toolchain_configure",
        helm_version = version
    )

    http_archive(
        name = "helm_linux",
        sha256 = linux_amd64_sha,
        urls = ["https://get.helm.sh/helm-v{version}-linux-amd64.tar.gz".format(version = version)],
        build_file = "@com_github_com_github_masmovil_bazel_rules//:helm.BUILD",
    )

    http_archive(
        name = "helm_darwin",
        sha256 = darwin_amd64_sha,
        urls = ["https://get.helm.sh/helm-v{version}-darwin-amd64.tar.gz".format(version = version)],
        build_file = "@com_github_com_github_masmovil_bazel_rules//:helm.BUILD",
    )


    http_archive(
        name = "helm_darwin_arm64",
        sha256 = darwin_arm64_sha,
        urls = ["https://get.helm.sh/helm-v{version}-darwin-arm64.tar.gz".format(version = version)],
        build_file = "@com_github_com_github_masmovil_bazel_rules//:helm.BUILD",
    )



    http_archive(
        name = "helm_windows",
        sha256 = windows_amd64_sha,
        urls = ["https://get.helm.sh/helm-v{version}-windows-amd64.tar.gz".format(version = version)],
        build_file = "@com_github_com_github_masmovil_bazel_rules//:helm.BUILD",
    )

    native.register_toolchains(
        "@mm_helm_toolchain_configure//:helm_linux_toolchain",
        "@mm_helm_toolchain_configure//:helm_osx_toolchain",
        "@mm_helm_toolchain_configure//:helm_osx_arm64_toolchain",
        "@mm_helm_toolchain_configure//:helm_windows_toolchain"
    )

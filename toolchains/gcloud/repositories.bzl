load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

def _gcloud_toolchain_configure_impl(repository_ctx):
    environ = repository_ctx.os.environ
    gcloud_version = repository_ctx.attr.gcloud_version

    repository_ctx.template(
        "BUILD.bazel",
        Label("@masmovil_bazel_rules//toolchains/gcloud:BUILD.tpl"),
        {
            "%{VERSION}": gcloud_version,
        },
        False,
    )

gcloud_toolchain_configure = repository_rule(
    implementation = _gcloud_toolchain_configure_impl,
    attrs = {
        "gcloud_version": attr.string(
            mandatory = True,
            doc = "Gcloud version to configure"
        )
    },
)

def gcloud_configure(version, linux_sha, darwin_sha, windows_sha, darwin_arm64_sha):
    gcloud_toolchain_configure(
        name = "mm_gcloud_toolchain_configure",
        gcloud_version = version
    )

    http_archive(
        name = "gcloud_linux",
        sha256 = linux_sha,
        urls = ["https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-{version}-linux-x86_64.tar.gz".format(version = version)],
        build_file = "@masmovil_bazel_rules//toolchains/gcloud:gcloud.BUILD",
    )

    http_archive(
        name = "gcloud_darwin",
        sha256 = darwin_sha,
        urls = ["https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-{version}-darwin-x86_64.tar.gz".format(version = version)],
        build_file = "@masmovil_bazel_rules//toolchains/gcloud:gcloud.BUILD",
    )

    http_archive(
        name = "gcloud_darwin_arm64",
        sha256 = darwin_arm64_sha,
        urls = ["https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-{version}-darwin-arm.tar.gz".format(version = version)],
        build_file = "@masmovil_bazel_rules//toolchains/gcloud:gcloud.BUILD",
    )

    http_archive(
        name = "gcloud_windows",
        sha256 = windows_sha,
        urls = ["https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-{version}-windows-x86_64.zip".format(version = version)],
        build_file = "@masmovil_bazel_rules//toolchains/gcloud:gcloud.BUILD",
    )

    native.register_toolchains(
        "@mm_gcloud_toolchain_configure//:gcloud_linux_toolchain",
        "@mm_gcloud_toolchain_configure//:gcloud_osx_toolchain",
        "@mm_gcloud_toolchain_configure//:gcloud_osx_arm64_toolchain",
        "@mm_gcloud_toolchain_configure//:gcloud_windows_toolchain"
    )

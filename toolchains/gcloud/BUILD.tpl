package(default_visibility = ["//visibility:private"])

load("@com_github_masmovil_bazel_rules//toolchains/gcloud:toolchain.bzl", "gcloud_toolchain")

gcloud_toolchain(
    name = "gcloud_linux",
    tools = "@gcloud_linux//:gcloud",
    version = "{VERSION}",
    visibility = ["//visibility:public"],
)

gcloud_toolchain(
    name = "gcloud_darwin",
    tools = "@gcloud_darwin//:gcloud",
    version = "{VERSION}",
    visibility = ["//visibility:public"],
)

gcloud_toolchain(
    name = "gcloud_darwin_arm64",
    tools = "@gcloud_darwin_arm64//:gcloud",
    version = "{VERSION}",
    visibility = ["//visibility:public"],
)

gcloud_toolchain(
    name = "gcloud_windows",
    tools = "@gcloud_windows//:gcloud",
    version = "{VERSION}",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "gcloud_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":gcloud_linux",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/gcloud:toolchain_type",
)

toolchain(
    name = "gcloud_osx_toolchain",
    exec_compatible_with = [
        "@platforms//os:osx",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":gcloud_darwin",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/gcloud:toolchain_type",
)

toolchain(
    name = "gcloud_osx_arm64_toolchain",
    exec_compatible_with = [
        "@platforms//os:osx"
        "@platforms//cpu:arm64",
    ],
    toolchain = ":gcloud_darwin",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/gcloud:toolchain_type",
)

toolchain(
    name = "gcloud_windows_toolchain",
    exec_compatible_with = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":gcloud_windows",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/gcloud:toolchain_type",
)

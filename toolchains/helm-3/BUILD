package(default_visibility = ["//visibility:private"])

load("//toolchains/helm:helm_toolchain.bzl", "helm_toolchain")

toolchain_type(name = "toolchain_type")

# Helm toolchain that points to helm binary version 3
helm_toolchain(
    name = "helm_v3.2.3_darwin",
    tool = "@helm_v3.2.3_darwin//:helm",
    helm_version = "3.2.3",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "helm_v3.2.3_linux",
    tool = "@helm_v3.2.3_linux//:helm",
    helm_version = "3.2.3",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "helm_v3.2.3_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":helm_v3.2.3_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "helm_v3.2.3__osx_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:osx",
    ],
    toolchain = ":helm_v3.2.3_darwin",
    toolchain_type = ":toolchain_type",
)

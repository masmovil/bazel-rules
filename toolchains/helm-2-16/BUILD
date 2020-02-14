package(default_visibility = ["//visibility:public"])

load("//toolchains/helm:helm_toolchain.bzl", "helm_toolchain")

toolchain_type(name = "toolchain_type")

# Helm toolchain that points to helm binary version 2.16.1
helm_toolchain(
    name = "helm_v2.16.1_darwin",
    tool = "@helm_v2.16.1_darwin//:helm",
    helm_version = "2.16.1",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "helm_v2.16.1_linux",
    tool = "@helm_v2.16.1_linux//:helm",
    helm_version = "2.16.1",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "helm_v2.16.1_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":helm_v2.16.1_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "helm_v2.16.1__osx_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:osx",
    ],
    toolchain = ":helm_v2.16.1_darwin",
    toolchain_type = ":toolchain_type",
)

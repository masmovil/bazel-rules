package(default_visibility = ["//visibility:private"])

load(":helm_toolchain.bzl", "helm_toolchain")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])

# Helm toolchain that points to helm binary version 2.13.0
helm_toolchain(
    name = "helm_v2.13.0_darwin",
    tool = "@helm_v2.13.0_darwin//:helm",
    helm_version = "2.13.0",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "helm_v2.13.0_linux",
    tool = "@helm_v2.13.0_linux//:helm",
    helm_version = "2.13.0",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "helm_v2.13.0_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":helm_v2.13.0_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "helm_v2.13.0_osx_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:osx",
    ],
    toolchain = ":helm_v2.13.0_darwin",
    toolchain_type = ":toolchain_type",
)

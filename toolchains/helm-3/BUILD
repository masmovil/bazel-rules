package(default_visibility = ["//visibility:private"])

load(":toolchain.bzl", "helm_toolchain")

toolchain_type(name = "toolchain_type")

toolchain(
    name = "helm_v3.8.0_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = "@helm_toolchain_configure//:helm_v3.8.0_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "helm_v3.8.0_osx_toolchain",
    target_compatible_with = [
        "@platforms//os:osx",
    ],
    toolchain = "@helm_toolchain_configure//:helm_v3.8.0_darwin",
    toolchain_type = ":toolchain_type",
)

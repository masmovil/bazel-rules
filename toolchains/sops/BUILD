package(default_visibility = ["//visibility:private"])

load(":sops_toolchain.bzl", "sops_toolchain")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])

# Sops toolchain that points to sops binary version 3.5.0
helm_toolchain(
    name = "sops_darwin",
    tool = "@sops_darwin//file",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "sops_linux",
    tool = "@sops_linux//file",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "sops_windows",
    tool = "@sops_linux//file",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "sops_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":sops_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "sops_osx_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:osx",
    ],
    toolchain = ":sops_darwin",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "sops_wnidows_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:windows",
    ],
    toolchain = ":sops_windows",
    toolchain_type = ":toolchain_type",
)

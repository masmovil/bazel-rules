package(default_visibility = ["//visibility:private"])

load(":sops_toolchain.bzl", "sops_toolchain")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])

# Sops toolchain that points to sops binary version 3.7.3
sops_toolchain(
    name = "sops_darwin_amd64",
    tool = "@sops_darwin_amd64//file",
    visibility = ["//visibility:public"],
)

sops_toolchain(
    name = "sops_darwin_arm64",
    tool = "@sops_darwin_arm64//file",
    visibility = ["//visibility:public"],
)

sops_toolchain(
    name = "sops_linux_amd64",
    tool = "@sops_linux_amd64//file",
    visibility = ["//visibility:public"],
)

sops_toolchain(
    name = "sops_linux_arm64",
    tool = "@sops_linux_arm64//file",
    visibility = ["//visibility:public"],
)

sops_toolchain(
    name = "sops_windows",
    tool = "@sops_windows//file",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "sops_linux_amd64_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":sops_linux_amd64",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "sops_linux_arm64_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:arm64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:arm64",
    ],
    toolchain = ":sops_linux_arm64",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "sops_osx_amd64_toolchain",
    target_compatible_with = [
        "@platforms//os:osx",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":sops_darwin_amd64",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "sops_osx_arm64_toolchain",
    target_compatible_with = [
        "@platforms//os:osx",
        "@platforms//cpu:arm64",
    ],
    toolchain = ":sops_darwin_arm64",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "sops_windows_toolchain",
    target_compatible_with = [
        "@platforms//os:windows",
    ],
    toolchain = ":sops_windows",
    toolchain_type = ":toolchain_type",
)

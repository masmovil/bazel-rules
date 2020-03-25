package(default_visibility = ["//visibility:private"])

load(":gpg_toolchain.bzl", "gpg_toolchain")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])

# Helm toolchain that points to gpg binary
gpg_toolchain(
    name = "gpg_darwin",
    tool = "//toolchains/gpg/lib:gpg_darwin_exec",
    visibility = ["//visibility:public"],
)

gpg_toolchain(
    name = "gpg_linux",
    tool = "//toolchains/gpg/lib:gpg_linux_exec",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "gpg_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":gpg_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "gpg_osx_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:osx",
    ],
    toolchain = ":gpg_darwin",
    toolchain_type = ":toolchain_type",
)

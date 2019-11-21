package(default_visibility = ["//visibility:private"])

load(":yq_toolchain.bzl", "yq_toolchain")

toolchain_type(name = "toolchain_type")

# Default yq toolchain that expects the 'yq' executable
# to be in the PATH.
yq_toolchain(
    name = "yq_default",
    tool_path = "yq",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "yq_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":yq_default",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "yq_osx_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:osx",
    ],
    toolchain = ":yq_default",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "barc_windows_toolchain",
    exec_compatible_with = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":yq_default",
    toolchain_type = ":toolchain_type",
)
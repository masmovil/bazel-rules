package(default_visibility = ["//visibility:private"])

load(":yq_toolchain.bzl", "yq_toolchain")

toolchain_type(name = "toolchain_type")

# Default yq toolchain that expects the 'yq' executable
# to be in the PATH.
yq_toolchain(
    name = "yq_linux",
    tool = "@yq_v2.4.1_linux//file",
    visibility = ["//visibility:public"],
)

yq_toolchain(
    name = "yq_osx",
    tool = "@yq_v2.4.1_darwin//file",
    visibility = ["//visibility:public"],
)

yq_toolchain(
    name = "yq_windows",
    tool = "yq",
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
    toolchain = ":yq_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "yq_osx_toolchain",
    target_compatible_with = [
        "@platforms//os:osx",
    ],
    toolchain = ":yq_osx",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "yq_windows_toolchain",
    exec_compatible_with = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":yq_windows",
    toolchain_type = ":toolchain_type",
)

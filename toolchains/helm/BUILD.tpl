package(default_visibility = ["//visibility:private"])

load("@com_github_masmovil_bazel_rules//toolchains/helm:toolchain.bzl", "helm_toolchain")

helm_toolchain(
    name = "helm_linux",
    tool = "@helm_linux//:helm",
    version = "{VERSION}",
    xdg_data_home = "%{HOME}/Library",
    xdg_config_home = "%{HOME}/Library/Preferences",
    xdg_cache_home = "%{HOME}/Library/Caches",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "helm_darwin",
    tool = "@helm_darwin//:helm",
    version = "{VERSION}",
    xdg_data_home = "%{HOME}/Library",
    xdg_config_home = "%{HOME}/Library/Preferences",
    xdg_cache_home = "%{HOME}/Library/Caches",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "helm_darwin_arm64",
    tool = "@helm_darwin//:helm",
    version = "{VERSION}",
    xdg_data_home = "%{HOME}/Library",
    xdg_config_home = "%{HOME}/Library/Preferences",
    xdg_cache_home = "%{HOME}/Library/Caches",
    visibility = ["//visibility:public"],
)

helm_toolchain(
    name = "helm_windows",
    tool = "@helm_windows//:helm",
    version = "{VERSION}",
    xdg_data_home = "%{HOME}/Library",
    xdg_config_home = "%{HOME}/Library/Preferences",
    xdg_cache_home = "%{HOME}/Library/Caches",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "helm_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":helm_linux",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type",
)

toolchain(
    name = "helm_osx_toolchain",
    exec_compatible_with = [
        "@bazel_tools//platforms:osx",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":helm_darwin",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type",
)

toolchain(
    name = "helm_osx_arm64_toolchain",
    exec_compatible_with = [
        "@bazel_tools//platforms:osx",
        "@platforms//cpu:arm64",
    ],
    toolchain = ":helm_darwin_arm64",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type",
)

toolchain(
    name = "helm_windows_toolchain",
    exec_compatible_with = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":helm_windows",
    toolchain_type = "@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type",
)

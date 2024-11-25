load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies", "aspect_bazel_lib_register_toolchains")
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
load("@aspect_bazel_lib//lib:repositories.bzl", "register_coreutils_toolchains")
load("//:toolchains.bzl", "masorange_rules_helm_toolchains_repos")


def mm_config():
    # toolchains
    masorange_rules_helm_toolchains_repos()

    # aspect_bazel_lib
    aspect_bazel_lib_dependencies()
    aspect_bazel_lib_register_toolchains()
    register_coreutils_toolchains()

    # bazel_skylib
    bazel_skylib_workspace()

    # rules_pkg
    rules_pkg_dependencies()

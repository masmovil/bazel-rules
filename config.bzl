load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies", "aspect_bazel_lib_register_toolchains")
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
load("@aspect_bazel_lib//lib:repositories.bzl", "register_coreutils_toolchains")
load("//:toolchains.bzl", "masorange_rules_helm_register_toolchains")


def masorange_rules_helm_configure():
    # toolchains
    masorange_rules_helm_register_toolchains()

    # aspect_bazel_lib
    aspect_bazel_lib_dependencies()
    aspect_bazel_lib_register_toolchains()
    register_coreutils_toolchains()

    # bazel_skylib
    bazel_skylib_workspace()

    # rules_pkg
    rules_pkg_dependencies()

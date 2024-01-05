load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(
    glob(["*.bzl"]),
    visibility = ["//docs:__pkg__"],
)

exports_files(["k8s_namespace.sh.tpl"])

bzl_library(
    name = "k8s_namespace",
    srcs = ["k8s_namespace.bzl"],
    visibility = [
        "//docs:__pkg__",
        "//helm:__subpackages__",
        "//k8s:__subpackages__",
    ],
    deps = [],
)

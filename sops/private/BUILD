
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(
    glob(["*.bzl"]),
    visibility = ["//docs:__pkg__"],
)

exports_files(["sops-decrypt.sh.tpl"])

bzl_library(
    name = "sops_decrypt",
    srcs = ["sops_decrypt.bzl"],
    visibility = [
        "//docs:__pkg__",
        "//sops:__subpackages__",
    ],
    deps = [],
)

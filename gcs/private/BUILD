load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(["gcs-upload.sh.tpl"])

exports_files(
    glob(["*.bzl"]),
    visibility = ["//docs:__pkg__"],
)

bzl_library(
    name = "gcs_upload",
    srcs = ["gcs_upload.bzl"],
    visibility = [
        "//docs:__pkg__",
        "//helm:__subpackages__",
    ],
    deps = [],
)

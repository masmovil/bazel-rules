load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "gcs",
    srcs = ["gcs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//gcs/private:gcs_upload",
    ],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//gcs/private:gcs_upload",
    ],
)

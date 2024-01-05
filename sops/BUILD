load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "sops",
    srcs = ["sops.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//sops/private:sops_decrypt",
    ],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//sops/private:sops_decrypt",
    ],
)

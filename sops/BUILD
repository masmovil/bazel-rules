load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

toolchain_type(name = "sops_toolchain_type", visibility = ["//visibility:public"])

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

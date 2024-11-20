load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

toolchain_type(name = "kubectl_toolchain_type", visibility = ["//visibility:public"])

bzl_library(
    name = "k8s",
    srcs = ["k8s.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//k8s/private:k8s_namespace",
    ],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//k8s/private:k8s_namespace",
    ],
)

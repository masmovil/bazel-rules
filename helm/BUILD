load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

exports_files(
    glob(["*.bzl"]),
    visibility = ["//docs:__pkg__"],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//helm/private:chart_srcs",
        "//helm/private:helm_chart_providers",
        "//helm/private:helm_lint",
        "//helm/private:helm_chart",
        "//helm/private:helm_pull",
        "//helm/private:helm_push",
        "//helm/private:helm_release",
        "//helm/private:helm_uninstall",
    ],
)

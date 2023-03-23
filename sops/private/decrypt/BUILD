package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_binary(
    name = "sops_decrypt",
    embed = [":go_default_library"],
)

go_library(
    name = "go_default_library",
    srcs = [
        "flags.go",
        "main.go",
    ],
    importpath = "github.com/masmovil/bazel-rules/sops/private/decrypt",
    deps = [
        "@com_github_sirupsen_logrus//:go_default_library",
        "@com_github_spf13_pflag//:go_default_library",
        "@org_mozilla_go_sops_v3//decrypt:go_default_library",
    ],
)

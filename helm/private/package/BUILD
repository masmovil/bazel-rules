package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library", "go_test")

go_binary(
    name = "helm_package",
    embed = [":go_default_library"],
)

go_library(
    name = "go_default_library",
    srcs = [
        "flags.go",
        "image.go",
        "package.go",
    ],
    importpath = "github.com/masmovil/bazel-rules/helm/private/package",
    deps = [
        "@com_github_pkg_errors//:go_default_library",
        "@com_github_sirupsen_logrus//:go_default_library",
        "@com_github_spf13_pflag//:go_default_library",
        "@io_k8s_sigs_yaml//:go_default_library",
        "@sh_helm_helm_v3//pkg/chart:go_default_library",
        "@sh_helm_helm_v3//pkg/chart/loader:go_default_library",
        "@sh_helm_helm_v3//pkg/chartutil:go_default_library",
        "@sh_helm_helm_v3//pkg/strvals:go_default_library",
        "//helm/private/lib/chart:go_default_library",
    ],
)


go_test(
    name = "go_default_test",
    srcs = [
        "image_test.go",
    ],
    embed = [":go_default_library"],
    deps = [
        "@com_github_stretchr_testify//assert:go_default_library",
        "@com_github_stretchr_testify//suite:go_default_library",
    ],
)

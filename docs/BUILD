load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")
load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")

stardoc(
    name = "helm_chart_docs",
    input = "//helm:defs.bzl",
    out = "helm_chart.md",
    symbol_names = ["helm_chart", "chart_srcs", "ChartInfo"],
    deps = [
        "//helm:defs",
    ],
)

stardoc(
    name = "helm_push_docs",
    input = "//helm/private:helm_push.bzl",
    out = "helm_push.md",
    deps = ["//helm/private:helm_push"],
)

stardoc(
    name = "helm_pull_docs",
    input = "//helm/private:helm_pull.bzl",
    out = "helm_pull.md",
    deps = ["//helm/private:helm_pull"],
)

stardoc(
    name = "helm_lint_docs",
    input = "//helm/private:helm_lint_test.bzl",
    out = "helm_lint.md",
    deps = ["//helm/private:helm_lint"],
)

stardoc(
    name = "helm_release_docs",
    input = "//helm/private:helm_release.bzl",
    out = "helm_release.md",
    deps = ["//helm/private:helm_release"],
)

stardoc(
    name = "helm_uninstall_docs",
    input = "//helm/private:helm_uninstall.bzl",
    out = "helm_uninstall.md",
    deps = ["//helm/private:helm_uninstall"],
)

write_source_files(
    name = "write_docs_md",
    files = {
        "helm_chart.md": ":helm_chart_docs",
        "helm_push.md": ":helm_push_docs",
        "helm_pull.md": ":helm_pull_docs",
        "helm_lint.md": ":helm_lint_docs",
        "helm_release.md": ":helm_release_docs",
        "helm_uninstall.md": ":helm_uninstall_docs",
    },
)

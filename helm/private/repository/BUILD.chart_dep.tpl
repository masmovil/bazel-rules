package(default_visibility = ["//visibility:public"])

load(
  "@com_github_masmovil_bazel_rules//helm:def.bzl",
  "helm_chart",
)

helm_chart(
  name = "chart",
  chart_name = "{CHART_NAME}",
  version = "{CHART_VERSION}",
  srcs = glob(["**"], exclude = ["BUILD.bazel", "WORKSPACE"]),
)

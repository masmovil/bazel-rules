package(default_visibility = ["//visibility:public"])

load("//helm:helm-chart-package.bzl", "helm_chart")

helm_chart(
  name = "dependencies_package",
  srcs = glob(["**"]),
  image_tag  = "latest",
  image_repository  = "gcr.io/lab/package-image-url",
  helm_chart_version = "1.0.0",
  package_name = "deps-bazel-rules-example",
  values_tag_yaml_path = "image.tag",
  values_repo_yaml_path = "image.repository",
  chart_deps = ["//examples/base-package:base_package"]
)
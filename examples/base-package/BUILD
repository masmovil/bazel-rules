package(default_visibility = ["//visibility:public"])

load("//helm:helm-chart-package.bzl", "helm_chart")

helm_chart(
  name = "base_package",
  srcs = glob(["**"]),
  image_tag  = "latest",
  image_repository  = "gcr.io/lab/base-replaced-by-rule-image-url",
  helm_chart_version = "1.0.0",
  package_name = "base-package",
  values_tag_yaml_path = "image.tag",
  values_repo_yaml_path = "image.repository",
)
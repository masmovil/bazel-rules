package(default_visibility = ["//visibility:public"])

load("//helm:helm-chart-package.bzl", "helm_chart")
load("//helm:helm-release.bzl", "helm_release")

helm_chart(
  name = "nginx_chart_with_deps",
  srcs = glob(["**"]),
  image_tag  = "latest",
  image_repository  = "nginx",
  helm_chart_version = "1.0.0",
  package_name = "nginx-with-deps",
  values_tag_yaml_path = "image.tag",
  values_repo_yaml_path = "image.repository",
  chart_deps = ["//tests/charts/nginx:nginx_chart"]
)

helm_release(
  name = "nginx_helm_release_with_deps",
  chart = ":nginx_chart_with_deps",
  namespace = "test-nginx-with-deps",
  release_name = "test-nginx-with-deps",
  values_yaml = glob(["values.yaml"]),
  tiller_namespace = "tiller-system"
)
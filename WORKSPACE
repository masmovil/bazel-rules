workspace(name = "com_github_masmovil_bazel_rules")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download the rules_docker repository at release v0.9.0
http_archive(
  name = "io_bazel_rules_docker",
  sha256 = "e513c0ac6534810eb7a14bf025a0f159726753f97f74ab7863c650d26e01d677",
  strip_prefix = "rules_docker-0.9.0",
  urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.9.0/rules_docker-v0.9.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)
container_repositories()

# This is NOT needed when going through the language lang_image
# "repositories" function(s).
load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load("//repositories:repositories.bzl", "repositories")

repositories()

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)

container_pull(
  name = "nginx",
  registry = "eu.gcr.io",
  repository = "mm-cloudbuild/mysim/tomcat",
  digest = "sha256:b72b782acb1069b5ac5eda64251faa4879bd4a17e9364d8688ec0570f06ae3ff"
)
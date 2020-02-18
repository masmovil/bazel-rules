load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def helm_repositories():
  http_archive(
    name = "helm_v2.16.1_darwin",
    sha256 = "34fc397ec4a992a451d130a962944315ca782242bbd05a8d732a2e74ca2b9153",
    urls = ["https://get.helm.sh/helm-v2.16.1-darwin-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v2.16.1_linux",
    sha256 = "7eebaaa2da4734242bbcdced62cc32ba8c7164a18792c8acdf16c77abffce202",
    urls = ["https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v2.13.0_darwin",
    sha256 = "166318b2159613f87a7cb02af1614c96244b3d3c119f8e010429c1b4449681d5",
    urls = ["https://get.helm.sh/helm-v2.13.0-darwin-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v2.13.0_linux",
    sha256 = "15eca6ad225a8279de80c7ced42305e24bc5ac60bb7d96f2d2fa4af86e02c794",
    urls = ["https://get.helm.sh/helm-v2.13.0-linux-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

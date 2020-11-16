load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def helm_repositories():
  http_archive(
    name = "helm_v2.17.0_darwin",
    sha256 = "104dcda352985306d04d5d23aaf5252d00a85c083f3667fd013991d82f57ae83",
    urls = ["https://get.helm.sh/helm-v2.17.0-darwin-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v2.17.0_linux",
    sha256 = "f3bec3c7c55f6a9eb9e6586b8c503f370af92fe987fcbf741f37707606d70296",
    urls = ["https://get.helm.sh/helm-v2.17.0-linux-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v3.4.1_darwin",
    sha256 = "71d213d63e1b727d6640c4420aee769316f0a93168b96073d166edcd3a425b3d",
    urls = ["https://get.helm.sh/helm-v3.4.1-darwin-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v3.4.1_linux",
    sha256 = "538f85b4b73ac6160b30fd0ab4b510441aa3fa326593466e8bf7084a9c288420",
    urls = ["https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )
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
    name = "helm_v3.6.2_darwin",
    sha256 = "81a94d2877326012b99ac0737517501e5ed69bb4987884e7f2d0887ad27895a9",
    urls = ["https://get.helm.sh/helm-v3.6.2-darwin-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v3.6.2_linux",
    sha256 = "f3a4be96b8a3b61b14eec1a35072e1d6e695352e7a08751775abf77861a0bf54",
    urls = ["https://get.helm.sh/helm-v3.6.2-linux-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

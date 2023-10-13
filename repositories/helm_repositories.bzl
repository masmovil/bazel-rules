load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def helm_repositories():
  http_archive(
    name = "helm_v2.17.0_darwin",
    sha256 = "104dcda352985306d04d5d23aaf5252d00a85c083f3667fd013991d82f57ae83",
    urls = ["https://get.helm.sh/helm-v2.17.0-darwin-amd64.tar.gz"],
    build_file = "@masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v2.17.0_linux",
    sha256 = "f3bec3c7c55f6a9eb9e6586b8c503f370af92fe987fcbf741f37707606d70296",
    urls = ["https://get.helm.sh/helm-v2.17.0-linux-amd64.tar.gz"],
    build_file = "@masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v3.8.0_darwin",
    sha256 = "532ddd6213891084873e5c2dcafa577f425ca662a6594a3389e288fc48dc2089",
    urls = ["https://get.helm.sh/helm-v3.8.0-darwin-amd64.tar.gz"],
    build_file = "@masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v3.8.0_linux",
    sha256 = "8408c91e846c5b9ba15eb6b1a5a79fc22dd4d33ac6ea63388e5698d1b2320c8b",
    urls = ["https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz"],
    build_file = "@masmovil_bazel_rules//:helm.BUILD",
  )

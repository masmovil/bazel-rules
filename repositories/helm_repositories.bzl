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
    name = "helm_v3.12.2_darwin",
    sha256 = "6e8bfc84a640e0dc47cc49cfc2d0a482f011f4249e2dff2a7e23c7ef2df1b64e",
    urls = ["https://get.helm.sh/helm-v3.12.2-darwin-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

  http_archive(
    name = "helm_v3.12.2_linux",
    sha256 = "2b6efaa009891d3703869f4be80ab86faa33fa83d9d5ff2f6492a8aebe97b219",
    urls = ["https://get.helm.sh/helm-v3.12.2-linux-amd64.tar.gz"],
    build_file = "@com_github_masmovil_bazel_rules//:helm.BUILD",
  )

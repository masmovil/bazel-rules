load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def kubectl_repositories():
  http_file(
    name = "kubectl_darwin",
    sha256 = "9b45260bb16f251cf2bb4b4c5f90bc847ab752c9c936b784dc2bae892e10205a",
    urls = ["https://storage.googleapis.com/kubernetes-release/release/v1.16.1/bin/darwin/amd64/kubectl"],
    executable = True
  )

  http_file(
    name = "kubectl_linux",
    sha256 = "69cfb3eeaa0b77cc4923428855acdfc9ca9786544eeaff9c21913be830869d29",
    urls = ["https://storage.googleapis.com/kubernetes-release/release/v1.16.1/bin/linux/amd64/kubectl"],
    executable = True
  )
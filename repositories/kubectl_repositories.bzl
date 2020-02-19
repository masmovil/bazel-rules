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
    # sha256 = "f0fd9fe2b0e09dc9ed190239fce892a468cbb0a2a8fffb9fe846f893c8fd09de",
    urls = ["https://storage.googleapis.com/kubernetes-release/release/v1.16.1/bin/linux/amd64/kubectl"],
    executable = True
  )
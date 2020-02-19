load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def kubectl_repositories():
  http_archive(
    name = "kubectl_darwin",
    # sha256 = "aacb6ce8ffa08eebc4e4a570226675f53963c86feb8386d46abf4b8871066c92",
    urls = ["https://storage.googleapis.com/kubernetes-release/release/v1.16.1/bin/darwin/amd64/kubectl"],
    build_file = "@com_github_masmovil_bazel_rules//:kubectl.BUILD",
  )

  http_archive(
    name = "kubectl_linux",
    # sha256 = "f0fd9fe2b0e09dc9ed190239fce892a468cbb0a2a8fffb9fe846f893c8fd09de",
    urls = ["https://storage.googleapis.com/kubernetes-release/release/v1.16.1/bin/linux/amd64/kubectl"],
    build_file = "@com_github_masmovil_bazel_rules//:kubectl.BUILD",
  )
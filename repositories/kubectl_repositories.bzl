load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def kubectl_repositories():
  http_file(
    name = "kubectl_darwin",
    sha256 = "e74efd3f6998cb51da707cc2e04b23e04ab90bea585be94d487ac545c6393ef9",
    urls = ["https://dl.k8s.io/v1.25.13/bin/darwin/amd64/kubectl"],
    executable = True
  )

  http_file(
    name = "kubectl_darwin_arm",
    sha256 = "41ed5aba120d3a078fc5086e866d02c42720f312f15836b29b1c77a7b8794119",
    urls = ["https://dl.k8s.io/v1.25.13/bin/darwin/arm64/kubectl"],
    executable = True
  )

  http_file(
    name = "kubectl_linux",
    sha256 = "22c5d5cb95b671ea7d7accd77e60e4a787b6d40a6b8ba4d6c364cb3ca818c29a",
    urls = ["https://dl.k8s.io/v1.25.13/bin/linux/amd64/kubectl"],
    executable = True
  )

  http_file(
    name = "kubectl_linux_arm",
    sha256 = "90bb3c9126b64f5eee2bef5a584da8bf0a38334e341b427b6986261af5f0d49b",
    urls = ["https://dl.k8s.io/v1.25.13/bin/linux/arm64/kubectl"],
    executable = True
  )

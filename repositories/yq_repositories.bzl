load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def yq_repositories():
  http_file(
    name = "yq_v2.4.1_linux",
    urls = ["https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64"],
    executable = True
  )

  http_file(
    name = "yq_v2.4.1_darwin",
    urls = ["https://github.com/mikefarah/yq/releases/download/2.4.1/yq_darwin_amd64"],
    sha256 = "06732685917646c0bbba8cc17386cd2a39b214ad3cd128fb4b8b410ed069101c",
    executable = True
  )

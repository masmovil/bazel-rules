load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def yq_repositories():
  http_file(
    name = "yq_v4.35.1_linux",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64"],
    sha256 = "9cbed984fa42e6d4873af020112c8d8627ec9e88a638ada771487d97f3367cad",
    executable = True
  )

  http_file(
    name = "yq_v4.35.1_linux_arm64",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_arm64"],
    sha256 = "0e76045e90045247f5c3f1752ce4442169be8e0ff2243c07b0f2800a4ee7fb4c",
    executable = True
  )

  http_file(
    name = "yq_v4.35.1_darwin",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_darwin_amd64"],
    sha256 = "52dd4639d5aa9dda525346dd74efbc0f017d000b1570b8fa5c8f983420359ef9",
    executable = True
  )

  http_file(
    name = "yq_v4.35.1_darwin_arm64",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_darwin_arm64"],
    sha256 = "47d5867c705cc04cb34ae7349b18ac03f1c2d2589da650e3cc57bcf865ee3411",
    executable = True
  )

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def yq_repositories():
  http_file(
    name = "yq_v4.35.1_linux",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64"],
    sha256 = "bd695a6513f1196aeda17b174a15e9c351843fb1cef5f9be0af170f2dd744f08",
    executable = True
  )

  http_file(
    name = "yq_v4.35.1_linux_arm64",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_arm64"],
    sha256 = "1d830254fe5cc2fb046479e6c781032976f5cf88f9d01a6385898c29182f9bed",
    executable = True
  )

  http_file(
    name = "yq_v4.35.1_darwin",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_darwin_amd64"],
    sha256 = "b2ff70e295d02695b284755b2a41bd889cfb37454e1fa71abc3a6ec13b2676cf",
    executable = True
  )

  http_file(
    name = "yq_v4.35.1_darwin_arm64",
    urls = ["https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_darwin_arm64"],
    sha256 = "e9fc15db977875de982e0174ba5dc2cf5ae4a644e18432a4262c96d4439b1686",
    executable = True
  )

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def sops_repositories():
  http_file(
    name = "sops_darwin_amd64",
    sha256 = "d62c9a4404197b5e56b59a4974caeb44086dd8cc9a5dba903e949d3a0a8e1350",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.darwin.amd64"],
    executable = True
  )

  http_file(
    name = "sops_darwin_arm64",
    sha256 = "be9ce265c7f3d3b534535d2a5ef7b41600bf2b8241b1a4f95e48804d20628b2e",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.darwin.arm64"],
    executable = True
  )

  http_file(
    name = "sops_linux_amd64",
    sha256 = "53aec65e45f62a769ff24b7e5384f0c82d62668dd96ed56685f649da114b4dbb",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64"],
    executable = True
  )

  http_file(
    name = "sops_linux_arm64",
    sha256 = "4945313ed0dfddba52a12ab460d750c91ead725d734039493da0285ad6c5f032",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.arm64"],
    executable = True
  )

  http_file(
    name = "sops_windows",
    sha256 = "0ccda78bc7f7dbf3f07167221f2a42cab2b10d02de7c26fe8e707efaacaf3bd2",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.exe"],
    executable = True
  )

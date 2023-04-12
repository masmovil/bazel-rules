load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def sops_repositories():
  http_file(
    name = "sops_darwin_amd64",
    sha256 = "d62c9a4404197b5e56b59a4974caeb44086dd8cc9a5dba903e949d3a0a8e1350",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.darwin.amd64"],
    executable = True,
  )

  http_file(
    name = "sops_darwin_arm64",
    sha256 = "be9ce265c7f3d3b534535d2a5ef7b41600bf2b8241b1a4f95e48804d20628b2e",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.darwin.arm64"],
    executable = True,
  )

  http_file(
    name = "sops_linux",
    # sha256 = "610fca9687d1326ef2e1a66699a740f5dbd5ac8130190275959da737ec52f096",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux"],
    executable = True
  )

  http_file(
    name = "sops_windows",
    # sha256 = "69cfb3eeaa0b77cc4923428855acdfc9ca9786544eeaff9c21913be830869d29",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.exe"],
    executable = True
  )
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def sops_repositories():
  http_file(
    name = "sops_darwin",
    sha256 = "795f03364ed8499d169505021b443226b5a9ee9e8a58f560188a133870d194c9",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.5.0/sops-v3.5.0.darwin"],
    executable = True
  )

  http_file(
    name = "sops_linux",
    # sha256 = "69cfb3eeaa0b77cc4923428855acdfc9ca9786544eeaff9c21913be830869d29",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.5.0/sops-v3.5.0.linux"],
    executable = True
  )

  http_file(
    name = "sops_windows",
    # sha256 = "69cfb3eeaa0b77cc4923428855acdfc9ca9786544eeaff9c21913be830869d29",
    urls = ["https://github.com/mozilla/sops/releases/download/v3.5.0/sops-v3.5.0.exe"],
    executable = True
  )
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@com_github_masmovil_bazel_rules//repositories:helm_repositories.bzl", "helm_repositories")
load("@com_github_masmovil_bazel_rules//repositories:yq_repositories.bzl", "yq_repositories")
load("@com_github_masmovil_bazel_rules//repositories:kubectl_repositories.bzl", "kubectl_repositories")

def repositories():
  """Download dependencies of container rules."""
  excludes = native.existing_rules().keys()

  kubectl_repositories()
  helm_repositories()
  yq_repositories()

  native.register_toolchains(
    # Register the default docker toolchain that expects the 'docker'
    # executable to be in the PATH
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_windows_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm:helm_v2.13.0_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm:helm_v2.13.0_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-2-16:helm_v2.16.1_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-2-16:helm_v2.16.1__osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-3:helm_v3.1.0_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-3:helm_v3.1.0__osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/kubectl:kubectl_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/kubectl:kubectl_osx_toolchain",
  )

  # ============================== Docker repositories ==============================
  if "io_bazel_rules_docker" not in excludes:
    http_archive(
      name = "io_bazel_rules_docker",
      sha256 = "df13123c44b4a4ff2c2f337b906763879d94871d16411bf82dcfeba892b58607",
      strip_prefix = "rules_docker-0.13.0",
      urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.13.0/rules_docker-v0.13.0.tar.gz"],
    )

    native.register_toolchains(
      # Register the default docker toolchain that expects the 'docker'
      # executable to be in the PATH
      "@io_bazel_rules_docker//toolchains/docker:default_linux_toolchain",
      "@io_bazel_rules_docker//toolchains/docker:default_windows_toolchain",
      "@io_bazel_rules_docker//toolchains/docker:default_osx_toolchain",
    )

  # ============================== bazel_skylib repositories ==============================
  if "bazel_skylib" not in excludes:
    http_archive(
        name = "bazel_skylib",
        sha256 = "e5d90f0ec952883d56747b7604e2a15ee36e288bb556c3d0ed33e818a4d971f2",
        strip_prefix = "bazel-skylib-1.0.2",
        urls = ["https://github.com/bazelbuild/bazel-skylib/archive/1.0.2.tar.gz"],
    )
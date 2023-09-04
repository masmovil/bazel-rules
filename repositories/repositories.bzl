load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@com_github_masmovil_bazel_rules//repositories:helm_repositories.bzl", "helm_repositories")
load("@com_github_masmovil_bazel_rules//repositories:yq_repositories.bzl", "yq_repositories")
load("@com_github_masmovil_bazel_rules//repositories:kubectl_repositories.bzl", "kubectl_repositories")
load("@com_github_masmovil_bazel_rules//repositories:sops_repositories.bzl", "sops_repositories")

load(
    "@com_github_masmovil_bazel_rules//toolchains/helm-3:toolchain.bzl",
    _helm_toolchain_configure = "helm_toolchain_configure",
)

def repositories():
  """Download dependencies of container rules."""
  excludes = native.existing_rules().keys()

  kubectl_repositories()
  helm_repositories()
  yq_repositories()
  sops_repositories()

  _helm_toolchain_configure(
    name = "helm_toolchain_configure"
  )

  native.register_toolchains(
    # Register the default docker toolchain that expects the 'docker'
    # executable to be in the PATH
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_linux_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_osx_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_windows_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm:helm_v2.17.0_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm:helm_v2.17.0_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-3:helm_v3.12.2_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-3:helm_v3.12.2_linux_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-3:helm_v3.12.2_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/helm-3:helm_v3.12.2_osx_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/kubectl:kubectl_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/kubectl:kubectl_linux_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/kubectl:kubectl_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/kubectl:kubectl_osx_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/sops:sops_linux_amd64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/sops:sops_linux_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/sops:sops_osx_amd64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/sops:sops_osx_arm64_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/sops:sops_windows_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/gpg:gpg_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/gpg:gpg_linux_toolchain"
  )

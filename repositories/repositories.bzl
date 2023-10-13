load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@masmovil_bazel_rules//repositories:helm_repositories.bzl", "helm_repositories")
load("@masmovil_bazel_rules//repositories:yq_repositories.bzl", "yq_repositories")
load("@masmovil_bazel_rules//repositories:kubectl_repositories.bzl", "kubectl_repositories")
load("@masmovil_bazel_rules//repositories:sops_repositories.bzl", "sops_repositories")
load("@masmovil_bazel_rules//toolchains/gcloud:def.bzl", "gcloud_configure")

load(
    "@masmovil_bazel_rules//toolchains/helm-3:toolchain.bzl",
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

  gcloud_configure(
    version = "371.0.0",
    linux_sha = "5691a6e3a762b937fe07cca30e9a37bc26c62016ea395e42dbd7bb72512d8e44",
    darwin_sha = "190604173fdb97ef7238b80f22f30f1d5032b0864b6af07a22a5f381ecfab1b5",
    darwin_arm64_sha = "b47bcd6c6c39f4602727fc94270a114a9a97d6382c1dedbf5df2ce595829f7a1",
    windows_sha = "e5eebe161d33f425d796fef15a823f0cf6db84f3ec1c42e18d5f0329a0ae1f7b"
  )

  native.register_toolchains(
    # Register the default docker toolchain that expects the 'docker'
    # executable to be in the PATH
    "@masmovil_bazel_rules//toolchains/yq:yq_linux_toolchain",
    "@masmovil_bazel_rules//toolchains/yq:yq_osx_toolchain",
    "@masmovil_bazel_rules//toolchains/yq:yq_windows_toolchain",
    "@masmovil_bazel_rules//toolchains/helm:helm_v2.17.0_linux_toolchain",
    "@masmovil_bazel_rules//toolchains/helm:helm_v2.17.0_osx_toolchain",
    "@masmovil_bazel_rules//toolchains/helm-3:helm_v3.8.0_linux_toolchain",
    "@masmovil_bazel_rules//toolchains/helm-3:helm_v3.8.0_osx_toolchain",
    "@masmovil_bazel_rules//toolchains/kubectl:kubectl_linux_toolchain",
    "@masmovil_bazel_rules//toolchains/kubectl:kubectl_osx_toolchain",
    "@masmovil_bazel_rules//toolchains/sops:sops_linux_amd64_toolchain",
    "@masmovil_bazel_rules//toolchains/sops:sops_linux_arm64_toolchain",
    "@masmovil_bazel_rules//toolchains/sops:sops_osx_amd64_toolchain",
    "@masmovil_bazel_rules//toolchains/sops:sops_osx_arm64_toolchain",
    "@masmovil_bazel_rules//toolchains/sops:sops_windows_toolchain",
    "@masmovil_bazel_rules//toolchains/gpg:gpg_osx_toolchain",
    "@masmovil_bazel_rules//toolchains/gpg:gpg_linux_toolchain"
  )

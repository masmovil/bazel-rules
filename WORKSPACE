workspace(name = "com_github_masmovil_bazel_rules")

register_toolchains(
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_windows_toolchain",
    # Target patterns are also permitted, so we could have also written:
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

load("//repositories:repositories.bzl", "repositories")

repositories()

load("//repositories:docker_deps.bzl", "docker_deps")

docker_deps()
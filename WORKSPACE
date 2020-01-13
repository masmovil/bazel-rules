workspace(name = "com_github_masmovil_bazel_rules")

register_toolchains(
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_windows_toolchain",
    # Target patterns are also permitted, so we could have also written:
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download the rules_docker repository at release v0.13.0
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "df13123c44b4a4ff2c2f337b906763879d94871d16411bf82dcfeba892b58607",
    strip_prefix = "rules_docker-0.13.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.13.0/rules_docker-v0.13.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)
container_repositories()

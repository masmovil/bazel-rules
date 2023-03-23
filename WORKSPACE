workspace(name = "com_github_masmovil_bazel_rules")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "685052b498b6ddfe562ca7a97736741d87916fe536623afb7da2824c0211c369",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.33.0/rules_go-v0.33.0.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.33.0/rules_go-v0.33.0.zip",
    ],
)

http_archive(
    name = "bazel_gazelle",
    sha256 = "448e37e0dbf61d6fa8f00aaa12d191745e14f07c31cabfa731f0c8e8a4f41b97",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.28.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.28.0.tar.gz",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_download_sdk", "go_register_toolchains", "go_rules_dependencies")

GO_SDK_VERSION = "1.18.3"

go_download_sdk(
    name = "go_sdk_linux",
    goarch = "amd64",
    goos = "linux",
    version = GO_SDK_VERSION,
)

go_download_sdk(
    name = "go_sdk_darwin",
    goarch = "amd64",
    goos = "darwin",
    version = GO_SDK_VERSION,
)

go_download_sdk(
    name = "go_sdk_darwin_arm64",
    goarch = "arm64",
    goos = "darwin",
    version = GO_SDK_VERSION,
)

go_rules_dependencies()

go_register_toolchains()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

# gazelle:repository_macro go_repositories.bzl%go_repositories
load("@//:go_repositories.bzl", "go_repositories")

go_repositories()

http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "b1e80761a8a8243d03ebca8845e9cc1ba6c82ce7c5179ce2b295cd36f7e394bf",
    # strip_prefix = "rules_docker-0.25.0",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.25.0/rules_docker-v0.25.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//toolchains/docker:toolchain.bzl",
    docker_toolchain_configure = "toolchain_configure",
)
load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load("//repositories:repositories.bzl", "repositories")

repositories()

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)

container_pull(
  name = "nginx",
  registry = "eu.gcr.io",
  repository = "mm-cloudbuild/mysim/tomcat",
  digest = "sha256:b72b782acb1069b5ac5eda64251faa4879bd4a17e9364d8688ec0570f06ae3ff"
)

load("//helm:def.bzl", "helm_chart_dependency")

helm_chart_dependency(
    name = "redis",
    repo_url = "https://charts.bitnami.com/bitnami",
    chart_name = "redis",
    chart_version = "17.8.5",
    sha256 = "8aa479fc3ed05605ffac6803ba4959032e7be473c1b24ebc8bac6d4643b34017"
)

git_repository(
    name = "com_google_protobuf",
    commit = "fe1790ca0df67173702f70d5646b82f48f412b99",  #v3.11.2
    remote = "https://github.com/protocolbuffers/protobuf.git",
    shallow_since = "1576187991 -0800",
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

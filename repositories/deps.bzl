load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_DOCKER_VERSION = "0.13.0"
RULES_DOCKER_URL = (
  "https://github.com/bazelbuild/rules_docker/releases/download/v{version}/rules_docker-v{version}.tar.gz"
)
RULES_DOCKER_SHA = "df13123c44b4a4ff2c2f337b906763879d94871d16411bf82dcfeba892b58607"

def _load_repo_deps_impl(ctx):
  if "io_bazel_rules_docker" not in native.existing_rules():
    ctx.download_and_extract(
        url =  RULES_DOCKER_URL.format(version = RULES_DOCKER_VERSION),
        sha256 = RULES_DOCKER_SHA,
    )


repository = repository_rule(
    implementation = _load_repo_deps_impl,
)

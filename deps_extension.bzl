def _non_module_dependencies_impl(_ctx):
    docker_repo(name = "io_bazel_rules_docker")

non_module_dependencies = module_extension(
    implementation = _non_module_dependencies_impl,
)

def _docker_repo_impl (rctx):
    rctx.download_and_extract(
        url = "https://github.com/bazelbuild/rules_docker/releases/download/v0.25.0/rules_docker-v0.25.0.tar.gz",
    )

docker_repo = repository_rule(
    implementation = _docker_repo_impl,
    doc = "Fetch external docker_rules",
    attrs = {},
)

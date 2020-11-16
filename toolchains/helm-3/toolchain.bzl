HelmToolchainInfo = provider(
    doc = "Helm toolchain",
    fields = {
        "helm_version": "Helm specific version",
        "tool": "Helm executable binary",
        "helm_xdg_data_home": "Helm data home path",
        "helm_xdg_config_home": "Helm config home path",
        "helm_xdg_cache_home": "Helm cache home path"
    },
)

def _helm_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        helminfo = HelmToolchainInfo(
            helm_version = ctx.attr.helm_version,
            tool = ctx.attr.tool,
            helm_xdg_data_home = ctx.attr.helm_xdg_data_home,
            helm_xdg_config_home = ctx.attr.helm_xdg_config_home,
            helm_xdg_cache_home = ctx.attr.helm_xdg_cache_home
        ),
    )
    return [toolchain_info]

helm_toolchain = rule(
    implementation = _helm_toolchain_impl,
    attrs = {
        "helm_version": attr.string(),
        "tool": attr.label(allow_single_file = True),
        "helm_xdg_data_home": attr.string(),
        "helm_xdg_config_home": attr.string(),
        "helm_xdg_cache_home": attr.string()
    },
)

def _helm_toolchain_configure_impl(repository_ctx):
    environ = repository_ctx.os.environ

    repository_ctx.template(
        "BUILD",
        Label("@com_github_masmovil_bazel_rules//toolchains/helm-3:BUILD.tpl"),
        {
            "%{HOME}": "%s" % environ["HOME"],
        },
        False,
    )

helm_toolchain_configure = repository_rule(
    implementation = _helm_toolchain_configure_impl,
    attrs = {
        "helm_xdg_data_home": attr.string(
            mandatory = False,
            doc = "Path directory for the helm xdg data home" +
                  "dir."
        ),
        "helm_xdg_config_home": attr.string(
            mandatory = False,
            doc = "Path directory for the helm config home" +
                  "dir."
        ),
        "helm_xdg_cache_home": attr.string(
            mandatory = False,
            doc = "Path directory for the helm xdg cache home" +
                  "dir."
        )
    },
    environ = [
        "HOME"
    ]
)
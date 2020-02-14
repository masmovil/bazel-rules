HelmToolchainInfo = provider(
    doc = "Helm toolchain",
    fields = {
        "helm_version": "Helm specific version",
        "tool": "Helm executable binary"
    },
)

def _helm_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        helminfo = HelmToolchainInfo(
            helm_version = ctx.attr.helm_version,
            tool = ctx.attr.tool
        ),
    )
    return [toolchain_info]

helm_toolchain = rule(
    implementation = _helm_toolchain_impl,
    attrs = {
        "helm_version": attr.string(),
        "tool": attr.label(allow_single_file = True),
    },
)
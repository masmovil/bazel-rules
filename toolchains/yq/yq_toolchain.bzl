YqToolchainInfo = provider(
    doc = "Yq toolchain rule parameters",
    fields = {
        "tool": "Path to the yq executable"
    },
)

def _yq_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        yqinfo = YqToolchainInfo(
            tool = ctx.attr.tool,
        ),
    )
    return [toolchain_info]

yq_toolchain = rule(
    implementation = _yq_toolchain_impl,
    attrs = {
        "tool": attr.label(allow_single_file = True),
    },
)
YqToolchainInfo = provider(
    doc = "Yq toolchain rule parameters",
    fields = {
        "tool_path": "Path to the yq executable"
    },
)

def _yq_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        yqinfo = YqToolchainInfo(
            tool_path = ctx.attr.tool_path,
        ),
    )
    return [toolchain_info]

yq_toolchain = rule(
    implementation = _yq_toolchain_impl,
    attrs = {
        "tool_path": attr.string(),
    },
)
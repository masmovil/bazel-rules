SopsToolchainInfo = provider(
    doc = "Sops toolchain",
    fields = {
        "tool": "Sops executable binary"
    }
)

def _sops_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        sopsinfo = SopsToolchainInfo(
            tool = ctx.attr.tool
        ),
    )
    return [toolchain_info]

sops_toolchain = rule(
    implementation = _sops_toolchain_impl,
    attrs = {
        "sops_version": attr.string(),
        "tool": attr.label(allow_single_file = True),
    },
)
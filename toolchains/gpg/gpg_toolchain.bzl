GpgToolchainInfo = provider(
    doc = "Gpg toolchain",
    fields = {
        "tool": "Gpg executable binary"
    },
)

def _gpg_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        gpginfo = GpgToolchainInfo(
            tool = ctx.attr.tool
        ),
    )
    return [toolchain_info]

gpg_toolchain = rule(
    implementation = _gpg_toolchain_impl,
    attrs = {
        "tool": attr.label(allow_single_file = True),
    },
)
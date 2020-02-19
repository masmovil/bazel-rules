KubectlToolchainInfo = provider(
    doc = "Kubectl toolchain",
    fields = {
        "tool": "Kubectl executable binary"
    },
)

def _kubectl_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        kubectlinfo = KubectlToolchainInfo(
            tool = ctx.attr.tool
        ),
    )
    return [toolchain_info]

kubectl_toolchain = rule(
    implementation = _kubectl_toolchain_impl,
    attrs = {
        "tool": attr.label(allow_single_file = True),
    },
)
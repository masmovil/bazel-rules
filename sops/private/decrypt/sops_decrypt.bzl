load("@bazel_skylib//lib:paths.bzl", "paths")

ChartInfo = provider(fields = [
    "chart",
    "chart_name",
    "chart_version",
    "transitive_deps"
])

def _sops_decrypt_impl(ctx):
    args = ctx.actions.args()
    inputs = [ctx.file.sops_yaml]
    outputs = []

    if ctx.attr.debug:
        debug = "true"
    else:
        debug = "false"

    args.add("--sops_config", ctx.file.sops_yaml.path)
    args.add("--debug", debug)

    for i, src in enumerate(ctx.files.srcs):
        out = ctx.actions.declare_file(src.basename)
        outputs.append(out)
        inputs.append(src)
        args.add("--f", src.path)
        args.add("--fo", out.path)

    ctx.actions.run(
        inputs = inputs,
        outputs = outputs,
        arguments = [args],
        env = {},
        tools = [],
        executable = ctx.file._bin_go,
        mnemonic = "sopsdecrypt"
    )

    direct_deps = depset(outputs)

    return [
        DefaultInfo(
            files = direct_deps
        ),
    ]

sops_decrypt = rule(
    implementation = _sops_decrypt_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "sops_yaml": attr.label(allow_single_file = True, mandatory = True),
        "provider": attr.string(default = "gcp_kms"),
        "debug": attr.bool(mandatory = False, default = False),
        "_bin_go": attr.label(allow_single_file = True, default = "@com_github_masmovil_bazel_rules//sops/private/decrypt:sops_decrypt"),
    },
    doc = "Decrypt secret files using sops",
)


_DOC = """
"""


def _sops_decrypt_impl(ctx):
    """This impl. allows reference and decrypt secrets.yaml files using mozilla sops
    Args:
        name: A unique name for this rule.
        srcs: Array of secret files to decrypt
        sops_yaml: Sops config file
    """
    sops = ctx.toolchains["@masmovil_bazel_rules//toolchains/sops:toolchain_type"].sopsinfo.bin

    inputs = [ctx.file.sops_yaml, sops]
    outputs = []

    for src in ctx.files.srcs:

        out_file = ctx.actions.declare_file("dec." + src.basename)

        args = ctx.actions.args()

        args.add("--decrypt", src.path)
        args.add("--config", ctx.file.sops_yaml.path)

        outputs.append(out_file)

        ctx.actions.run(
            inputs = inputs + [src],
            outputs = [out_file],
            arguments = [args],
            executable = sops,
            use_default_shell_env = True
        )

    return [
        DefaultInfo(
            files = depset(outputs)
        )
    ]

sops_decrypt = rule(
    implementation = _sops_decrypt_impl,
    doc = _DOC,
    attrs = {
      "srcs": attr.label_list(allow_files = True, mandatory = True, doc = ""),
      "sops_yaml": attr.label(allow_single_file = True, mandatory = True, doc = ""),
    },
    toolchains = [
        "@masmovil_bazel_rules//toolchains/sops:toolchain_type",
    ],
)

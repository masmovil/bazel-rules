def sopfile(ctx, f):
  """Return the sop file relative path of f."""
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path

# Load docker image providers
def _sops_decrypt_impl(ctx):
    """This impl. allows rerference and decrypr encrypted secrets.yaml files
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """
    inputs = [] + ctx.files.srcs
    outputs = []

    sops = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/sops:toolchain_type"].sopsinfo.tool.files.to_list()[0].path

    # declare output files based on src inputs
    for i, srcfile in enumerate(ctx.files.srcs):
      out = ctx.actions.declare_file(ctx.attr.package_name + "-" + srcfile.basename + ".dec")
      outputs.append(out)

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_bash")

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{DECRYPT_FILES}": "\n".join([
              "\tdecrypt_file %s" % sopfile(ctx, f)
              for f in ctx.files.srcs]),
            "{SOPS_BINARY_PATH}": sops,
            "{SOPS_CONFIG_FILE}": sops_yaml
        }
    )

    ctx.actions.run(
        inputs = inputs,
        outputs = outputs,
        arguments = [],
        executable = exec_file,
        execution_requirements = {
            "local": "1",
        },
    )

    return [
        DefaultInfo(
            files = depset(outputs)
        )
    ]

sops_decrypt = rule(
    implementation = _sops_decrypt_impl,
    attrs = {
      "srcs": attr.label_list(allow_files = True, mandatory = True),
      "sops_yaml": attr.label(allow_single_file = True, default = ":.sops.yaml"),
      "_script_template": attr.label(allow_single_file = True, default = ":sops-decrypt.sh.tpl"),
    },
    toolchains = [
        "@com_github_masmovil_bazel_rules//toolchains/sops:toolchain_type"
    ],
    doc = "Runs sops decrypt to decrypt secret files",
)

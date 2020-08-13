
load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")

NamespaceDataInfo = provider(fields=["namespace"])

def runfile(ctx, f):
  """Return the runfiles relative path of f."""
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path


def _k8s_namespace_impl(ctx):
    """Create a k8s namespace.
    Args:
        namespace_name: Name of the namespace to create
    """
    kubectl_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/kubectl:toolchain_type"].kubectlinfo.tool.files.to_list()
    kubectl_path = kubectl_binary[0].path

    namespace_name = ctx.attr.namespace_name

    stamp_files = [ctx.info_file, ctx.version_file]

    exec_file = ctx.actions.declare_file(ctx.label.name + "_k8s_bash")

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{NAMESPACE_NAME}": namespace_name,
            "{KUBECTL_PATH}": kubectl_path,
            "%{stamp_statements}": "\n".join([
              "read_variables %s" % runfile(ctx, f)
              for f in stamp_files]),
        }
    )

    runfiles = ctx.runfiles(
        files = [ctx.info_file, ctx.version_file]
    )

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    ),
    NamespaceDataInfo(
      namespace = namespace_name
    )]

k8s_namespace = rule(
    implementation = _k8s_namespace_impl,
    attrs = {
      "namespace_name": attr.string(mandatory = True),
      "_script_template": attr.label(allow_single_file = True, default = ":k8s-namespace.sh.tpl"),

    },
    doc = "Creates a new kubernetes namespace",
    toolchains = [
      "@com_github_masmovil_bazel_rules//toolchains/kubectl:toolchain_type"
    ],
    executable = True,
)

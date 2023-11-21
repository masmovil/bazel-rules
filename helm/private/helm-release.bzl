load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")
load("//k8s:k8s.bzl", "NamespaceDataInfo")

def runfile(ctx, f):
  """Return the runfiles relative path of f."""
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path

def _helm_release_impl(ctx):
    """Installs or upgrades a helm release.
    Args:
        name: A unique name for this rule.
        chart: Chart to install
        namespace: Namespace where release is installed to
        release_name: Name of the helm release
        values_yaml: Specify values yaml to override default
        secrets_yaml: Specify sops encrypted values to override defaulrt values (need to define sops_value as well)
        sops_yaml = Sops file if secrets_yaml is provided
    """
    helm_bin = ctx.toolchains["@masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.bin

    chart = ctx.file.chart
    tiller_namespace = ctx.attr.tiller_namespace
    release_name = ctx.attr.release_name
    kubernetes_context = ctx.attr.kubernetes_context
    create_namespace = ctx.attr.create_namespace
    wait = ctx.attr.wait
    stamp_files = [ctx.info_file, ctx.version_file]
    namespace = ctx.attr.namespace_dep[NamespaceDataInfo].namespace if ctx.attr.namespace_dep else ctx.attr.namespace

    values_yaml = ""
    for i, values_yaml_file in enumerate(ctx.files.values_yaml):
        values_yaml = values_yaml + " -f " + values_yaml_file.short_path

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_bash")


    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{CHART_PATH}": chart.short_path,
            "{NAMESPACE}": namespace,
            "{RELEASE_NAME}": release_name,
            "{VALUES_YAML}": values_yaml,
            "{HELM_PATH}": helm_bin.path,
            "{KUBERNETES_CONTEXT}": kubernetes_context,
            "{CREATE_NAMESPACE}": create_namespace,
            "{WAIT}": wait,
            "%{stamp_statements}": "\n".join([
              "\tread_variables %s" % runfile(ctx, f)
              for f in stamp_files]),
        }
    )

    runfiles = ctx.runfiles(
        files = [
            chart,
            ctx.info_file,
            ctx.version_file
        ] + ctx.files.values_yaml + ctx.files.secrets_yaml + ctx.files.sops_yaml + helm_bin
    )

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_release = rule(
    implementation = _helm_release_impl,
    attrs = {
      "chart": attr.label(allow_single_file = True, mandatory = True),
      "namespace_dep": attr.label(mandatory = False),
      "namespace": attr.string(mandatory = False, default = "default"),
      "release_name": attr.string(mandatory = True),
      "values_yaml": attr.label_list(allow_files = True, mandatory = False),
      "secrets_yaml": attr.label_list(allow_files = True, mandatory = False),
      "sops_yaml": attr.label(allow_single_file = True, mandatory = False),
      "kubernetes_context": attr.string(mandatory = False),
      "create_namespace": attr.string(mandatory = False, default = ""),
      "wait": attr.string(mandatory = False, default = ""),
      "_script_template": attr.label(allow_single_file = True, default = ":helm-release.sh.tpl"),
    },
    doc = "Installs or upgrades a new helm release",
    toolchains = [
        "@masmovil_bazel_rules//toolchains/helm:toolchain_type",
    ],
    executable = True,
)

# Load docker image providers
load(
    "@io_bazel_rules_docker//container:providers.bzl",
    "ImageInfo",
    "LayerInfo",
)

load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")

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
    helm_path = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.tool.files.to_list()[0].path
    helm_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.tool.files.to_list()
    chart = ctx.file.chart
    namespace = ctx.attr.namespace
    tiller_namespace = ctx.attr.tiller_namespace
    release_name = ctx.attr.release_name

    stamp_files = [ctx.info_file, ctx.version_file]

    values_yaml = ""
    for i, values_yaml_file in enumerate(ctx.files.values_yaml):
        values_yaml = values_yaml + " -f " + values_yaml_file.path

    secrets_yaml = ""
    for i, secrets_yaml_file in enumerate(ctx.files.secrets_yaml):
        secrets_yaml = secrets_yaml + " -f " + secrets_yaml_file.path

    if secrets_yaml != "" and not ctx.file.sops_yaml:
        fail(msg='sops_yaml must be provided if secrets_yaml is set')

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_bash")

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{CHART_PATH}": chart.short_path,
            "{NAMESPACE}": namespace,
            "{TILLER_NAMESPACE}": tiller_namespace,
            "{RELEASE_NAME}": release_name,
            "{VALUES_YAML}": values_yaml,
            "{HELM_PATH}": helm_path,
            "{SECRETS_YAML}": secrets_yaml,
            "%{stamp_statements}": "\n".join([
              "\tread_variables %s" % runfile(ctx, f)
              for f in stamp_files]),
        }
    )

    runfiles = ctx.runfiles(
        files = [chart, ctx.info_file, ctx.version_file] + ctx.files.values_yaml + ctx.files.secrets_yaml + ctx.files.sops_yaml + helm_binary
    )

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_release = rule(
    implementation = _helm_release_impl,
    attrs = {
      "chart": attr.label(allow_single_file = True, mandatory = True),
      "namespace": attr.string(mandatory = True, default = "default"),
      "tiller_namespace": attr.string(mandatory = True, default = "tiller-system"),
      "release_name": attr.string(mandatory = True),
      "values_yaml": attr.label_list(allow_files = True, mandatory = False),
      "secrets_yaml": attr.label_list(allow_files = True, mandatory = False),
      "sops_yaml": attr.label(allow_single_file = True, mandatory = False),
      "_script_template": attr.label(allow_single_file = True, default = ":helm-release.sh.tpl"),
    },
    doc = "Installs or upgrades a new helm release",
    toolchains = ["@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type"],
    executable = True,
)

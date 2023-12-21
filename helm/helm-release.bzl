# Load docker image providers
load(
    "@io_bazel_rules_docker//container:providers.bzl",
    "ImageInfo",
    "LayerInfo",
)

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
        namespace_dep: k8s_namespace label for the namesapce where release is installed
        namespace: Namespace where release is installed to, if namespace_dep not specified. Defaults to "default" - will change to "" in a future version
        release_name: Name of the helm release
        values_yaml: Specify values yaml to override default
        secrets_yaml: Specify sops encrypted values to override defaulrt values (need to define sops_value as well)
        sops_yaml = Sops file if secrets_yaml is provided
    """
    helm_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.tool.files.to_list()
    helm_path = helm_binary[0].path
    helm3_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/helm-3:toolchain_type"].helminfo.tool.files.to_list()
    helm3_path = helm3_binary[0].path
    kubectl_binary = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/kubectl:toolchain_type"].kubectlinfo.tool.files.to_list()
    kubectl_path = kubectl_binary[0].path

    chart = ctx.file.chart
    force = ctx.attr.force
    tiller_namespace = ctx.attr.tiller_namespace
    release_name = ctx.attr.release_name
    helm_version = ctx.attr.helm_version or ""
    kubernetes_context = ctx.attr.kubernetes_context
    create_namespace = ctx.attr.create_namespace
    wait = ctx.attr.wait
    wait_timeout = ctx.attr.wait_timeout
    stamp_files = [ctx.info_file, ctx.version_file]

    values_yaml = ""
    for i, values_yaml_file in enumerate(ctx.files.values_yaml):
        values_yaml = values_yaml + " -f " + values_yaml_file.short_path

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_bash")

    if ctx.attr.namespace_dep:
        namespace = ctx.attr.namespace_dep[NamespaceDataInfo].namespace
    else:
        namespace = ctx.attr.namespace

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{CHART_PATH}": chart.short_path,
            "{FORCE}": force,
            "{NAMESPACE}": namespace,
            "{TILLER_NAMESPACE}": tiller_namespace,
            "{TIMEOUT}": wait_timeout,
            "{RELEASE_NAME}": release_name,
            "{VALUES_YAML}": values_yaml,
            "{HELM_PATH}": helm_path,
            "{HELM3_PATH}": helm3_path,
            "{KUBECTL_PATH}": kubectl_path,
            "{FORCE_HELM_VERSION}": helm_version,
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
        ] + ctx.files.values_yaml + ctx.files.secrets_yaml + ctx.files.sops_yaml + helm_binary + helm3_binary + kubectl_binary
    )

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_release = rule(
    implementation = _helm_release_impl,
    attrs = {
      "chart": attr.label(allow_single_file = True, mandatory = True),
      "force": attr.string(mandatory = False, default = ""),  # could actually be a boolean
      "namespace_dep": attr.label(mandatory = False),
      "namespace": attr.string(mandatory = False, default = "default"),
      "tiller_namespace": attr.string(mandatory = False, default = "tiller-system"),
      "release_name": attr.string(mandatory = True),
      "values_yaml": attr.label_list(allow_files = True, mandatory = False),
      "secrets_yaml": attr.label_list(allow_files = True, mandatory = False),
      "sops_yaml": attr.label(allow_single_file = True, mandatory = False),
      "helm_version": attr.string(mandatory = False),
      "kubernetes_context": attr.string(mandatory = False),
      "create_namespace": attr.string(mandatory = False, default = ""),
      "wait": attr.string(mandatory = False, default = ""),  # could actually be a boolean
      "wait_timeout": attr.string(mandatory = False, default = ""),
      "_script_template": attr.label(allow_single_file = True, default = ":helm-release.sh.tpl"),
    },
    doc = "Installs or upgrades a new helm release",
    toolchains = [
        "@com_github_masmovil_bazel_rules//toolchains/helm:toolchain_type",
        "@com_github_masmovil_bazel_rules//toolchains/helm-3:toolchain_type",
        "@com_github_masmovil_bazel_rules//toolchains/kubectl:toolchain_type"
    ],
    executable = True,
)

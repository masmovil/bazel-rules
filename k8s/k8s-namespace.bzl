
load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")

NamespaceDataInfo = provider(fields=["namespace"])

def runfile(ctx, f):
  """Return the runfiles relative path of f."""
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path


def _k8s_namespace_impl(ctx):
    """Installs or upgrades a helm release.
    Args:
        namespace_name: Name of the namespace to create
        kubernetes_sa: Kubernetes Service Account to associate with Workload Identity. I.E. default
        gcp_sa_project: GCP project name where Service Account lives. I.E. my-project
        gcp_sa: GCP Service Account. I.E. my-account@my-project.iam.gserviceaccount.com
        workload_identity_namespace: Workload Identity Namespace. I.E. mm-k8s-dev-01.svc.id.goog

    """

    namespace_name = ctx.attr.namespace_name
    kubernetes_sa = ctx.attr.kubernetes_sa
    gcp_sa_project = ctx.attr.gcp_sa_project
    gcp_sa = ctx.attr.gcp_sa
    gcp_gke_project = ctx.attr.gcp_gke_project
    workload_identity_namespace = ctx.attr.workload_identity_namespace

    if gcp_sa != "":
        if kubernetes_sa == "":
             fail(msg='ERROR: kubernetes_sa must be provided if gcp_sa is set')
        if gcp_sa_project == "":
             fail(msg='ERROR: gcp_sa_project must be provided if gcp_sa is set')
        if gcp_gke_project == "":
             fail(msg='ERROR: gcp_gke_project must be provided if gcp_sa is set')
        if workload_identity_namespace == "":
             fail(msg='ERROR: workload_identity_namespace must be provided if gcp_sa is set')

    stamp_files = [ctx.info_file, ctx.version_file]


    exec_file = ctx.actions.declare_file(ctx.label.name + "_k8s_bash")

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{NAMESPACE_NAME}": namespace_name,
            "{KUBERNETES_SA}": kubernetes_sa,
            "{GCP_GKE_PROJECT}": gcp_gke_project,
            "{GCP_SA_PROJECT}": gcp_sa_project,
            "{GCP_SA}": gcp_sa,
            "{WORKLOAD_IDENTITY_NAMESPACE}": workload_identity_namespace,
            "{NAMESPACE_LABELS}": labels,
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
      "kubernetes_sa": attr.string(mandatory = True, default = "default"),
      "gcp_sa_project": attr.string(mandatory = False),
      "gcp_sa": attr.string(mandatory = False),
      "gcp_gke_project": attr.string(mandatory = False),
      "workload_identity_namespace": attr.string(mandatory = False),
      "labels":  attr.string_list(mandatory=False, allow_empty=True, *, default=[], doc='Labels for create namespace'),
      "_script_template": attr.label(allow_single_file = True, default = ":k8s-namespace.sh.tpl"),

    },
    doc = "Creates a new kubernetes namespace and annotates it with workload identity",
    toolchains = [],
    executable = True,
)

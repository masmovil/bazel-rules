
NamespaceDataInfo = provider(fields=["namespace"])

# Return the runfiles relative path of f
def _runfile(ctx, f):
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path

_DOC = """Create a kubernetes namespace in a kubernetes cluster with workload identity support. You can also configure GKE Workload Identity with it.

    To load the rule use:
    ```starlark
    load("//k8s:defs.bzl", "k8s_namespace")
    ```

    You can annotate the kubernetes namespace with a kubernetes service account, and bind the service account with
    gcp workload identity.

    This rule uses kubectl client to create and annotate the kubernetes namespace and gcloud sdk to create the bindings
    between the kubernetes service account and the gcp workload identity user.

    This rule builds an executable. Use `run` instead of `build` to be create the namespace.

    ```starlark
    load("//k8s:defs.bzl", "k8s_namespace")

    k8s_namespace(
        name = "namespace",
        namespace_name = "ft-sesame-${DEPLOY_BRANCH}",
        kubernetes_sa = "default",
        gcp_sa_project = "mm-odissey-dev",
        gcp_sa = "odissey-dev@mm-odissey-dev.iam.gserviceaccount.com",
        gcp_gke_project = "mm-k8s-dev-01",
        workload_identity_namespace = "mm-k8s-dev-01.svc.id.goog",
        kubernetes_context = "mm-k8s-context",
    )
    ```

  You can use `k8s_namespace` in combination with `helm_release` trough `napesmace_dep` attribute.

  Example of use with `helm_release`:

  ```starlark
    load("//k8s:defs.bzl", "k8s_namespace")

    k8s_namespace(
      name = "test-namespace",
      namespace_name = "test-namespace",
      kubernetes_sa = "test-kubernetes-sa",
      kubernetes_context = "mm-k8s-context",
    )
    helm_release(
        name = "chart_install",
        chart = ":chart",
        namespace_dep = ":test-namespace",
        tiller_namespace = "tiller-system",
        release_name = "release-name",
        values_yaml = glob(["charts/myapp/values.yaml"]),
        kubernetes_context = "mm-k8s-context",
    )
  ```
"""

_ATTRS = {
  "namespace_name": attr.string(mandatory = True, doc = "Name of the namespace to be created."),
  "kubernetes_sa": attr.string(mandatory = False, doc = "Kubernetes Service Account to associate with Workload Identity."),
  "gcp_sa_project": attr.string(mandatory = False, doc = "CP project name where Service Account lives."),
  "gcp_sa": attr.string(mandatory = False, doc = "GCP Service Account in e-mail format."),
  "gcp_gke_project": attr.string(mandatory = False, doc = ""),
  "workload_identity_namespace": attr.string(mandatory = False, doc = "Workload Identity Namespace e.g clustername.svc.id.goog"),
  "kubernetes_context": attr.string(mandatory = False, doc = ""),
  "_script_template": attr.label(allow_single_file = True, default = ":k8s_namespace.sh.tpl", doc = ""),
}

def _k8s_namespace_impl(ctx):
    kubectl_bin = ctx.toolchains["@masmovil_bazel_rules_test//k8s:kubectl_toolchain_type"].kubectlinfo.bin
    gcloud_bin = ctx.toolchains["@masmovil_bazel_rules_test//gcs:gcloud_toolchain_type"].gcloudinfo.gcloud_bin

    namespace_name = ctx.attr.namespace_name
    kubernetes_sa = ctx.attr.kubernetes_sa
    gcp_sa_project = ctx.attr.gcp_sa_project
    gcp_sa = ctx.attr.gcp_sa
    gcp_gke_project = ctx.attr.gcp_gke_project
    workload_identity_namespace = ctx.attr.workload_identity_namespace
    kubernetes_context = ctx.attr.kubernetes_context

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
            "{KUBECTL}": kubectl_bin.short_path,
            "{GCLOUD}": gcloud_bin.short_path,
            "{WORKLOAD_IDENTITY_NAMESPACE}": workload_identity_namespace,
            "{KUBERNETES_CONTEXT}": kubernetes_context,
            "%{stamp_statements}": "\n".join([
              "read_variables %s" % _runfile(ctx, f)
              for f in stamp_files]),
        }
    )

    runfiles = ctx.runfiles(
        files = [ctx.info_file, ctx.version_file, kubectl_bin, gcloud_bin]
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
    attrs = _ATTRS,
    doc = _DOC,
    toolchains = [
      "@masmovil_bazel_rules_test//gcs:gcloud_toolchain_type",
      "@masmovil_bazel_rules_test//k8s:kubectl_toolchain_type",
    ],
    executable = True,
)

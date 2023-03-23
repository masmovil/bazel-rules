### k8s_namespace

`k8s_namespace` is used to create a new namespace.
You can also configure GKE Workload Identity with it.

Example of use:
```python
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

Example of use with helm_release:
```python
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

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| namespace_name | yes | - | Name of the namespace to create |
| kubernetes_sa | no | - | Kubernetes Service Account to associate with Workload Identity. I.E. default It supports the use of `stamp_variables`. |
| kubernetes_sa | no | kube-system | Namespace where Tiller lives in the Kubernetes Cluster. It supports the use of `stamp_variables`.|
| gcp_sa_project | no | - |GCP project name where Service Account lives. I.E. `my-project`|
| gcp_sa | no | - | GCP Service Account. I.E.  `my-account@my-project.iam.gserviceaccount.com`|
| gcp_gke_project | no | - | GKE Project |
| workload_identity_namespace | no | - | Workload Identity Namespace. I.E. `mm-k8s-dev-01.svc.id.goog` |
| kubernetes_context | no | "" | Context of kubernetes cluster |

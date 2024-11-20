<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="helm_release"></a>

## helm_release

<pre>
load("@masmovil_bazel_rules//helm/private:helm_release.bzl", "helm_release")

helm_release(<a href="#helm_release-name">name</a>, <a href="#helm_release-chart">chart</a>, <a href="#helm_release-create_namespace">create_namespace</a>, <a href="#helm_release-kubernetes_context">kubernetes_context</a>, <a href="#helm_release-namespace">namespace</a>, <a href="#helm_release-namespace_dep">namespace_dep</a>,
             <a href="#helm_release-release_name">release_name</a>, <a href="#helm_release-set">set</a>, <a href="#helm_release-values">values</a>, <a href="#helm_release-values_yaml">values_yaml</a>, <a href="#helm_release-wait">wait</a>)
</pre>

  Installs or upgrades a helm release of a chart in to a cluster using helm binary.

  To load the rule use:
  ```starlark
  load("//helm:defs.bzl", "helm_release")
  ```

  This rule builds an executable. Use `run` instead of `build` to be install the release.

  ```starklark
helm_release(
    name = "chart_install",
    chart = ":chart",
    namespace = "myapp",
    tiller_namespace = "tiller-system",
    release_name = "release-name",
    values_yaml = glob(["charts/myapp/values.yaml"]),
    kubernetes_context = "mm-k8s-context",
)
```

Example of use with k8s_namespace:
```starklark
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

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="helm_release-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="helm_release-chart"></a>chart |  The packaged chart archive to be published. It can be a reference to a `helm_chart` rule or a reference to a helm archived file   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="helm_release-create_namespace"></a>create_namespace |  A flag to indicate helm binary to create the kubernetes namespace if it is not already present in the cluster.   | Boolean | optional |  `True`  |
| <a id="helm_release-kubernetes_context"></a>kubernetes_context |  Reference to a kubernetes context file used by helm binary.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="helm_release-namespace"></a>namespace |  The namespace literal where to install the helm release. Set to `""` to use namespace from current kube context   | String | optional |  `""`  |
| <a id="helm_release-namespace_dep"></a>namespace_dep |  A reference to a `k8s_namespace` rule from where to extract the namespace to be used to install the release.Namespace where this release is installed to. Must be a label to a k8s_namespace rule. It takes precedence over namespace   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="helm_release-release_name"></a>release_name |  The name of the helm release to be installed or upgraded.   | String | required |  |
| <a id="helm_release-set"></a>set |  A dictionary of key value pairs consisting on yaml paths and values to be replaced in the chart via --set helm option before installing it: "yaml.path": "value"   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="helm_release-values"></a>values |  A list of value files to be provided to helm install command through -f flag.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="helm_release-values_yaml"></a>values_yaml |  [Deprecated] Use `values` attr instead   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="helm_release-wait"></a>wait |  Helm flag to wait for all resources to be created to exit.   | Boolean | optional |  `True`  |



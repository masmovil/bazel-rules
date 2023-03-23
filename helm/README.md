# Helm rules

Helm rules to manipulate kubernetes helm charts.

This repo implements these bazel rules to manipulate charts:
- [`helm_chart` | `heml_package`](#helm_chart|helm_package) rule to create a new helm package.
- [`helm push`](#helm_push) rule used to publish helm packages to helm registries.
- [`helm_release`](#helm_release) rule used to install or update a release in a Kubernetes Cluster.
- [`helm_chart_dependency`](#helm_chart_dependency) a repository rule to import external helm charts.

## How to import

To import any helm rule you should load it from `def.bzl` file inside `helm` dir.

```python
load("@com_github_masmovil_bazel_rules//helm:def.bzl", "helm_chart", "helm_push", "helm_release", "helm_chart_dependency")
```

## Rules

### helm_chart | helm_package

You can use `helm_chart` rule to package a helm chart into a versioned chart archive file. It mimics the functionality of `helm package` command cli.
You can declare the helm chart referencing the chart sources (`templates`, `Chart.yaml` etc.) via `srcs` rule attribute, or define the chart in a declarative way using rule attributes.

The rule can replace some specific values of your app: the `image tag value`, the `image repository` and the helm package `version of the application`. The image can be provided either by `image_tag` attribute as string or by a `image` label attribute. The `image` attribute has to be a label that specify a [docker image bazel rule](https://github.com/bazelbuild/rules_docker). This rule will use docker image providers to extract the digest (sha256), and reference that sha256 as the image tag of the helm package.
The rule creates a tar.gz file in the bazel output directory. The name of the generated tar.gz will be the package_name + the chart version.

Example of use with source files:

```python
helm_chart(
  name = "app_package",
  srcs = glob(["**"]),
  image  = "//docker:app", # Reference to the docker image rule to extract the digest sha256 from
  chart_name = "app", # name of the helm package. This will be the name of the generated tar.gz helm package
  values_tag_yaml_path = "base.k8s.deployment.image.tag", # yaml Path of the image tag in the values.yaml files
  version = "0.1.1"
)
```

Example of use in a declarative way:

```python
helm_chart(
  name = "app_package",
  image  = "//docker:app", # Reference to the docker image rule to extract the digest sha256 from
  chart_name = "app", # Name of the helm package. This will be the name of the generated tar.gz helm package
  values_tag_yaml_path = "base.k8s.deployment.image.tag", # yaml Path of the image tag in the values.yaml files
  version = "0.1.1",
  app_version = "1.0.0",
  values = """
label: app
baseFn: app1
domain:
  name: test-tmp.dns.com
nginx:
  enabled: true
  proxy_passes:
  - location: /tmp/test/
    proxy_pass_to: https://test.dns.com/
"""
)
```

You can reference other helm packages defined with `helm_chart` rules as helm dependencies to this package. The output of `helm_chart` dependencies will be added to the generated output tar into the charts directory.

```python
helm_chart(
  ....,
  deps = [
    "//other-charts/chart-dep1:some_package1",
    "//other-charts/chart-dep2:some_package2"
  ]
  ....
)
```

If your chart depends on charts placed in other helm registries, you can use `helm_chart_dependency` to load them in the workspace [see below](#helm_chart_dependency).

**IMPORTANT NOTE:** Chart dependencies listed in `requirements.yaml` or `Chart.yaml` are not downloaded automatically by this rule. You need to declare them manually and added as dependencies of `deps` attr.
You should continue declaring this dependencies in the `Chart.yaml` or `requirements.yaml` file (`Chart.yaml` preferred as `requirements.yaml` is deprecated). This will help you to set up conditional values to enable or disable the chart dependency when installing it.

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory | Type | Default | Notes |
| ---------- | --- | ------ | -------------- |
| srcs | no | label_list | - | Chart source files. Must be a list of **bazel labels** (or a glob pattern) containing the path where the helm chart files and values are placed. Just one helm package should placed under `srcs` files. |
| image | no | label | - | Label referencing another bazel rule that implements [docker container image rule](https://github.com/bazelbuild/rules_docker#container_image-1). This attr is used to obtain the digest of the built docker image and use it as the docker image tag of the application. |
| image_tag | no | string | - | Fixed image tag value that will be used in the deployment. It can contain a string (e.g `master`).
Note: This attribute is an alternative to the `image` attribute if you want to provide a "fixed" image tag of your application instead of using a bazel rule to generate the docker image of your app. If you specify both, `image` attribute has preferenece.  |
| chart_name | yes | string | - | The name of the helm chart. It must be the same name that was defined in the Chart.yaml |
| description | no | string | - | Chart.yaml description |
| version | no | string | `1.0.0` | Version of the helm chart. It replaces the Chart.yaml version of the helm package. It has to be defined following the [semver](https://semver.org/) nomenclature. |
| app_version | no | string | - | Used to replace the Chart.yaml appVersion of the helm package, defaulting to traditional behavior of equaling the helm_chart_version if not given.  A freeform value should be fine, but following the [semver](https://semver.org/) nomenclature is recommended. |
| image_repository | no | string | - | The url of the docker registry where the docker image is stored. This is usually where the `image.repository` points to in the values.yaml file |
| values_repo_yaml_path | no | string | `image.repository` | The yaml path (expressed in dot notation) of values.yaml where the key of the image repository is defined in the values.yaml. |
| values_tag_yaml_path | no | string | `image.tag` | The yaml path (expressed in dot notation) of values.yaml where the key of the image tag is defined in the values.yaml |
| deps | no | label_list | - | Helm chart dependencies of this rules. Defined as a list of dependencies of other `helm_chart` rules (bazel targets). |
| templates | no | [string] | [] | List of labels or files to be added to the `templates/` folder of the chart. Useful for centralizing common templates and pass them around different charts. |
| value_files | no | [string] | [] | List of value files to be specified for the chart. This values have priority over default chart `values.yaml` file, and are merged in order (the last one values files in the array have priority over first ones..). All of this values content will be merged into one final values, that will be saved as the final chart values.yaml. |
| values | no | string | - | Explicit values defined for the chart. Has high precedence over `value_files` and chart default `values.yaml`.|
| files | no | [string] | [] | List of files to be added to the chart folder. Useful for add common files to the chart. |
| chart_tags | no | [string] | [] | Chart.yaml tags. |
| keywords | no | string | - | Chart.yaml keywords. |
| condition | no | string | - | Chart.yaml condition. |
| api_version | no | string |'v2' | Chart.yaml api version. |
| kube_version | no | string | - | Chart.yaml kube api version. |


### helm_push

`helm_push` is used to publish helm packages to a predefined helm repository. The rule will take a helm package (targz) and make a POST request to the defined repository, publishing the package to a helm registry.

This rule is an executable. It needs `run` instead of `build` to be invoked.

It authenticates against chart museum api using basic auth, so valid username and password have to be provided.

Example of use:
```python
helm_push(
  name = "flex_push",
  chart  = ":flex_package",
  repository_name = "masmovil",
  repository_url = "https://chartsapiurl.com/",
  repository_username = "{HELM_REPO_US}",
  repository_password = "{HELM_REPO_PASS}",
)
```

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| chart | yes | - | Chart package (targz). Must be a label that specifies where the helm package file (Chart.yaml) is. It accepts the path of the targz file (that bazel will resolve to the file) or the label to a target rule that generates a helm package as output (`helm_chart` rule). |
| repository_name | true | - | The name of the chart museum repository |
| repository_url | true | - | The url of the the chart museum repository. **IMPORTANT: The url must end with slash /**  |
| repository_username | true | - | The username to login in to the chart museum registry using basic auth. It supports the use of `make_variables` |
| repository_password | true | - | The password to login in to the chart museum registry using basic auth. It supports the use of `make_variables` |


### helm_release

`helm_release` is used to install helm releases in a Kubernetes Cluster.

This rule is an executable. It needs `run` instead of `build` to be invoked.

It relies in existing local kubernetes config (`~/.kube/config`).

Example of use:
```python
helm_release(
    name = "chart_install",
    chart = ":chart",
    namespace_name = "myapp",
    release_name = "release-name",
    values_yaml = glob(["charts/myapp/values.yaml"]),
    kubernetes_context = "mm-k8s-context",
)
```

Example of use with k8s_namespace:
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
| chart | yes | - | Chart package (targz). Must be a label that specifies where the helm package file (Chart.yaml) is. It accepts the path of the targz file (that bazel will resolve to the file) or the label to a target rule that generates a helm package as output (`helm_chart` rule). |
| namespace | false | default | Namespace name literal where this release is installed to. It supports the use of `stamp_variables`. |
| namespace_dep | false | - | Namespace where this release is installed to. Must be a label to a k8s_namespace rule. It takes precedence over namespace |
| release_name | yes | - | Name of the Helm release. It supports the use of `stamp_variables`|
| values_yaml | no | - | Several values files can be passed when installing release |
| helm_version | no | "" | Force the use of helm v2 or v3 to deploy the release. The attribute can be set to **v2** or **v3** |
| kubernetes_context | no | "" | Context of kubernetes cluster |

### helm_chart_dependency

Repository rule to download external helm charts. It supports helm registries.

You need to invoke it from the WORKSPACE.

```python
load("@com_github_masmovil_bazel_rules//helm:def.bzl", "helm_chart_dependency")


  helm_chart_dependency(
      name = "redis",
      repo_url = "https://charts.bitnami.com/bitnami",
      chart_name = "redis",
      chart_version = "10.5.7",
  )
```

Once the dependency is declared, you can reference it in a `helm_chart` rule as a dependency:

```pyhton
helm_chart(
  ....,
  deps = [
    "@redis//:chart",
  ]
  ....
)
```

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| repo_url | yes | - | Helm registry url. Must be a valid helm registry. |
| chart_name | yes | - | Name of the chart to download from the helm registry. It must exist in the specified registry. |
| chart_version | yes | - | Version of the chart to downlaod from the helm registry. It must exist. |
| sha256 | no | - | sha256 of the helm chart. |

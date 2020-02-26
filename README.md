# bazel rules

[![Build Status](https://travis-ci.com/masmovil/bazel-rules.svg?branch=master)](https://travis-ci.com/masmovil/bazel-rules)

This repository contains Bazel rules to install and manipulate Helm charts with Bazel.

There are three defined rules, `helm_chart` , `helm_push` and `helm_release`.

## Documentation

These rules generate new helm packages with specific values for each development version of your application and push generated helm packages to a provided [helm chart museum](https://chartmuseum.com/).

### Important notes

Helm v3 is now supported.

`helm_release` rule will check if tiller is installed in your cluster to decide which version of helm to use (v2 or v3).
If the rule can't find any deployed tiller in your cluster, it will use helm v3 by default.
To look up for any installed tiller in your cluster, the rule will use `tiller_namespace` attribute value.

You can force the use of helm v2 using `helm_v2` attribute (set to `True`, default `False`).

### Getting started

In your Bazel `WORKSPACE` file, after the [rules_docker](https://github.com/bazelbuild/rules_docker#setup), add this repository as a dependency and invoke repositories helper method:

```python
git_repository(
    name = "com_github_masmovil_bazel_rules",
    # tag = "0.2.2",
    commit = "commit-ref",
    remote = "https://github.com/masmovil/bazel-rules.git",
)

load(
    "@com_github_masmovil_bazel_rules//repositories:repositories.bzl",
    mm_repositories = "repositories",
)
mm_repositories()
```

After the intial setup, you can use the rules including them in your BUILD files:

```python
load("@com_github_masmovil_bazel_rules//helm:helm.bzl", "helm_chart", "helm_push", "helm_release")

helm_chart(
    name = "my_chart",
    srcs = glob(["**"]),
    ...
)

helm_push(
    name = "my_chart_push",
    srcs = glob(["**"]),
    ...
)

helm_release(
    name = "my_chart_push",
    ...
)
```

These rules use [yq library](https://yq.readthedocs.io/en/latest/) to perform substitions in helm YAML templates. The binaries are preloaded by this rule using bazel toolchains, so you don't need have yq available in your path.

## Helm rules

### helm_chart

You can use `helm_chart` rule to create a new helm package. Before creating the helm package, the rule can replace some specific values of your app: the image tag value, the image repository and the helm package version of the application. The image can be provided either by `image_tag` attribute as string/make variable or by a `image` label attribute. The `image` attribute has to be a label that specify a [docker image bazel rule](https://github.com/bazelbuild/rules_docker). This rule will extract the digest (sha256) automatically from that image, and reference that sha256 as the image tag of the helm package.
The rule creates a tar.gz file in the bazel output directory. The name of the generated tar.gz will be the package_name + the version of the Chart.yaml (the version can be override with the `helm_chart_version` attribute).

Example of use:
```python
helm_chart(
  name = "flex_package",
  srcs = glob(["**"]),
  image  = "//docker/flex:flex", // Reference to the docker image rule to extract the digest sha256 from
  package_name = "flex", // name of the helm package. This will be the name of the generated tar.gz helm package
  values_tag_yaml_path = "base.k8s.deployment.image.tag", // yaml Path of the image tag in the values.yaml files
  helm_chart_version = "v0.1.1"
)
```

You can reference other helm packages defined with `helm_chart` rules as helm dependencies of this package. The output of `helm_chart` dependencies will be added to the generated output tar into the charts directory.

```python
helm_chart(
  ....,
  chart_deps = [
    "//other-charts/chart-dep1:some_package1",
    "//other-charts/chart-dep2:some_package2"
  ]
  ....
)
```

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| srcs | yes | - | Chart source files. Must be a list of **bazel labels** (or a glob pattern) containing the path where the helm chart files and values are placed. Just one helm package should placed under `srcs` files. |
| image | no | - | Label referencing another bazel rule that implements [docker container image rule](https://github.com/bazelbuild/rules_docker#container_image-1). This attr is used to obtain the digest of the built docker image and use it as the docker image tag of the application. |
| image_tag | no | - | Fixed image tag value that will be used in the deployment. It can contain a string (e.g `master`), or the key of a make variable if is included in curly braces (e.g {GIT_COMMIT}). If a make variable format is used, the variable has to be provided through the `--define` method. Note: This attribute is an alternative to the `image` attribute if you want to provide a "fixed" image tag of your application instead of using a bazel rule to generate the docker image of your app. If you specify both, `image` attribute has preferenece.  |
| package_name | yes | - | The name of the helm package. It must be the same name that was defined in the Chart.yaml |
| helm_chart_version | no | `1.0.0` | Used to replace the Chart.yaml version of the helm package. It has to be defined following the [semver](https://semver.org/) nomenclature. Support make variables if the attribute is placed inside curly braces (e.g {HELM_VERSION})|
| image_repository | no | - | The url of the docker registry where the docker image is stored. This is usually where the `image.repository` points to in the values.yaml file |
| values_repo_yaml_path | no | `image.repository` | The yaml path (expressed in dot notation) of values.yaml where the key of the image repository is defined in the values.yaml. |
| values_tag_yaml_path | no | `image.tag` | The yaml path (expressed in dot notation) of values.yaml where the key of the image tag is defined in the values.yaml |
| chart_deps | no | - | Helm chart dependencies of this rules. Defined as a list of dependencies of other helm_chart rules (bazel targets). |


#### Use of make_variables
`image_tag` and `helm_chart_version` attributes support make variables. Make variables are provided to bazel through the `--define` argument.
To enable make variables, string values have to be inside curly braces `image_tag="{GIT_SHA}"`.

```python
bazel build //... --define GIT_SHA="ab2cxc4z9"


helm_chart(
  ...
  image_tag  = "{GIT_SHA}",
  ...
)
```

### helm_push

`helm_push` is used to publish new helm packages to a predefined [chart museum](https://chartmuseum.com/) repository. The rule will take a helm package (targz) and make a POST request to the defined chart museum, publishing the package to a helm registry.

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

`helm_release` is used to create and deploy a new release in a Kubernetes Cluster.

Only `Helm 2` is supported for the moment.

It has support for secrets via helm secrets (sops), which allows to have encrypted values files in the Git repository.

This rule is an executable. It needs `run` instead of `build` to be invoked.

It relies in existing local kubernetes config (`~/.kube/config`).

Example of use:
```python
helm_release(
    name = "chart_install",
    chart = ":chart",
    namespace = "myapp",
    tiller_namespace = "tiller-system",
    release_name = "release-name",
    values_yaml = glob(["charts/myapp/values.yaml"]),
    secrets_yaml = glob(["charts/myapp/secrets.*.yaml"]),
    sops_yaml = ".sops.yaml",
)
```

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| chart | yes | - | Chart package (targz). Must be a label that specifies where the helm package file (Chart.yaml) is. It accepts the path of the targz file (that bazel will resolve to the file) or the label to a target rule that generates a helm package as output (`helm_chart` rule). |
| namespace | yes | default | Namespace where this release is installed to. It supports the use of `stamp_variables`. |
| tiller_namespace | yes | kube-system | Namespace where Tiller lives in the Kubernetes Cluste. It supports the use of `stamp_variables`.|
| release_name | yes | - | Name of the Helm release. It supports the use of `stamp_variables`|
| values_yaml | no | - | Several values files can be passed when installing release |
| secrets_yaml | no | - | Several values files encryopted can be passed when installing release. **IMPORTANT: It requires `helm secrets` plugin to be installed and also define `sops_yaml` for sops configuration**  |
| sops_yaml | no | - | Provide when using `secrets_yaml`. Check  https://github.com/futuresimple/helm-secrets documentation for further information |
| helm_v2 | no | False | Force the use of helm v2 to deploy the release |


## K8s rules

Import in your `BUILD.bazel`

```python
load("@com_github_masmovil_bazel_rules//k8s:k8s.bzl", "k8s_namespace")

```


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
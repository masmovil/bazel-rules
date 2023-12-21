# bazel rules

![Build Status](https://github.com/masmovil/bazel-rules/actions/workflows/integration-tests.yaml/badge.svg)

This repository contains Bazel rules to install and manipulate Helm charts with Bazel.

This repo implements the following bazel rules:
 `helm_chart`
 `helm_push`
 `helm_release`
 `sops_decrypt`
 `k8s_namespace`

## Documentation

These rules generate new helm packages with specific values for each development version of your application and push generated helm packages to a provided [helm chart museum](https://chartmuseum.com/).

### Important notes

Helm v3 is now supported.

`helm_release` rule will check if tiller is installed in your cluster to decide which version of helm to use (v2 or v3).
If the rule can't find any deployed tiller in your cluster, it will use helm v3 by default.
To look up for any installed tiller in your cluster, the rule will use `tiller_namespace` attribute value.

You can force the use of helm v2 or helm v3 using `helm_version` attribute (set to `v2`, or `v3`).

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
The rule creates a tar.gz file in the bazel output directory. The name of the generated tar.gz will be the package_name.

Example of use:
```python
helm_chart(
  name = "flex_package",
  srcs = glob(["**"]),
  image  = "//docker/flex:flex", // Reference to the docker image rule to extract the digest sha256 from
  package_name = "flex", // name of the helm package. This will be the name of the generated tar.gz helm package
  values_tag_yaml_path = "base.k8s.deployment.image.tag", // yaml Path of the image tag in the values.yaml files
  helm_chart_version = "0.1.1"
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
| helm_chart_version | no | `1.0.0` | Used to replace the Chart.yaml version of the helm package. It has to be defined following the [semver](https://semver.org/) nomenclature. Support make variables if the attribute is placed inside curly braces (e.g {HELM_VERSION}) and stamped variables using the following nomenclature: ${HELM_VERSION}|
| app_version | no | helm_chart_version | Used to replace the Chart.yaml appVersion of the helm package, defaulting to traditional behavior of equaling the helm_chart_version if not given.  A freeform value should be fine, but following the [semver](https://semver.org/) nomenclature is recommended. Support make variables if the attribute is placed inside curly braces (e.g {APP_VERSION} but not {APP_VERSION}-some-suffix) and stamped variables using the following nomenclature: ${APP_VERSION}|
| image_repository | no | - | The url of the docker registry where the docker image is stored. This is usually where the `image.repository` points to in the values.yaml file |
| values_repo_yaml_path | no | `image.repository` | The yaml path (expressed in dot notation) of values.yaml where the key of the image repository is defined in the values.yaml. |
| values_tag_yaml_path | no | `image.tag` | The yaml path (expressed in dot notation) of values.yaml where the key of the image tag is defined in the values.yaml |
| chart_deps | no | - | Helm chart dependencies of this rules. Defined as a list of dependencies of other helm_chart rules (bazel targets). |
| additional_templates | no | [] | List of labels or files to be added to the `templates/` folder of the chart. Useful for centralizing common templates and pass them around different charts. |


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

#### Use of stamp variables

You can specify volatile variables in any attribute using the following sintaxis: `${}` e.g:
```python

helm_chart(
  ...
  helm_chart_version = "${VERSION}",
  ...
)
```
These variables have to be "exported" by the `status.sh` file defined in your project root dir.

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

`Helm 3` and `Helm 2` are supported.

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
| namespace | false | default | Namespace name literal where this release is installed to. It supports the use of `stamp_variables`. Set to `""` to use namespace from current kube context. ⚠️ Please note deprecations below |
| namespace_dep | false | - | Namespace where this release is installed to. Must be a label to a k8s_namespace rule. It takes precedence over namespace |
| tiller_namespace | false | kube-system | Namespace where Tiller lives in the Kubernetes Cluster. It supports the use of `stamp_variables`. Unnecessary using helm v3 |
| release_name | yes | - | Name of the Helm release. It supports the use of `stamp_variables`|
| values_yaml | no | - | Several values files can be passed when installing release |
| helm_version | no | "" | Force the use of helm v2 or v3 to deploy the release. The attribute can be set to **v2** or **v3** |
| kubernetes_context | no | "" | Context of kubernetes cluster |

#### ⚠️ Deprecations

The default value of the `namespace` attribute will be changing from `"default"` to `""`. `""` will use the namespace of the current kubernetes context and most users will see no change in behavour. If you are relying on charts being explicitly installed into the `default` namespace, please update your `BUILD` files to include `namespace = "default"`.

## Sops rules
Decrypting secrets using [sops](https://github.com/mozilla/sops) is now supported.

To install `sops_decrypt` rule, import in your `BUILD.bazel`

```python
load("@com_github_masmovil_bazel_rules//sops:sops.bzl", "sops_decrypt")
```

### sops_decrypt

You can decrypt as many secrets as you want using `sops_decrypt` rule. Use the rule attribute `src` to provide the encrypted secrets that you want to decrypt.
The rule also needs the sops config file with the keyring id in order to decrypt files (`.sops.yaml`). You can provide it using the `sops_yaml` rule attribute.

Example of use:
```python
sops_decrypt(
    name = "decrypt_secret_files",
    srcs = [":secrets.yaml"]
    sops_yaml = ":.sops.yaml"
)
```

You can specify which provider integration you want to use (gcp KMS, azure key vault etc.) through the `provider` attribute.
* For the moment only gcp KMS is supported

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| src | yes | - | One or more labels pointing to the secret files to decrypt. It accepts a glob pattern. |
| sops_yaml | yes | - | One label referencing the `.sops.yaml` yaml with the sops config. |
| provider | false | "gcp_kms" | The provider integration used to decrypt/encrypt the secrets. |

The output of the rule are the decrypted secrets that you can pass to `helm_release`.

Example of use:
```python
sops_decrypt(
    name = "decrypt_secret_files",
    srcs = [":secrets.yaml"]
    sops_yaml = ":.sops.yaml"
)

helm_release(
    name = "chart_install",
    chart = ":chart",
    namespace = "myapp",
    tiller_namespace = "tiller-system",
    release_name = "release-name",
    values_yaml = glob(["charts/myapp/values.yaml"]) + [":decrypt_secret_files"],
    kubernetes_context = "mm-k8s-context",
)
```

Env variables are supported by using --action_env flag running `sops_decrypt` rules. This is usefull in scenarios where you need to provide default credentials for cloud services (gcp kms, aws kms).

E.g:

```python
# GOOGLE_APPLICATION_CREDENTIALS env variable needs to be predefined
bazel build :decrypt_secret_files --action_env=GOOGLE_APPLICATION_CREDENTIALS

or

bazel build :decrypt_secret_files --action_env=GOOGLE_APPLICATION_CREDENTIALS=${HOME}/.config/gcloud/application_default_credentials.json
```

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


## GCS rules

Import in your `BUILD.bazel`

```python
load("@com_github_masmovil_bazel_rules//gcs:gcs.bzl", "gcs_upload")

```

**Gcloud SDK** is required in the system PATH.

### gcs_upload

`gcs_upload` is used to upload a single file to a Google Cloud Storage bucket

Example of use:
```python
gcs_upload(
    name = "push",
    src = ":file",
    destination = "gs://my-bucket/file.zip"
)
```


The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| src | yes | - | Source file label |
| destination | yes | - | Destination path in GCS (in form of`gs://mybucket/file`) It supports the use of `stamp_variables`. |

# bazel rules

This repository contains Bazel rules to install and manipulate Helm charts with Bazel.

There are two defined rules, `helm_chart` and `helm_push`.

## Documentation

These rules generate new helm packages with specific values for each development version of your application and push generated helm packages to a provided [helm chart museum](https://chartmuseum.com/).

### Getting started

In your Bazel `WORKSPACE` file add this repository as a dependency:

```
git_repository(
    name = "com_github_masmovil_bazel_rules",
    tag = "0.2.2",
    remote = "https://github.com/masmovil/bazel-rules.git",
)
```

Then in your BUILD files include the `helm_chart` and/or `helm_push` rules:

```
load("@com_github_masmovil_bazel_rules//helm:helm.bzl", "helm_chart", "helm_push")

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
```

### helm_chart

You can use `helm_chart` rule to create a new helm package. Before creating the helm package, the rule can replace some specific values of your app: the image tag value, the image repository and the helm package version of the application. The image can be provided either by `image_tag` attribute as string/make variable or by a `image` label attribute. The `image` attribute has to be a label that specify a [docker image bazel rule](https://github.com/bazelbuild/rules_docker). This rule will extract the digest (sha256) automatically from that image, and reference that sha256 as the image tag of the helm package.
The rule creates a tar.gz file in the bazel output directory. The name of the generated tar.gz will be the package_name + the version of the Chart.yaml (the version can be override with the `helm_chart_version` attribute).

Example of use:
```
helm_chart(
  name = "flex_package",
  srcs = glob(["**"]),
  image  = "//docker/flex:flex", // Reference to the docker image rule to extract the digest sha256 from
  package_name = "flex", // name of the helm package. This will be the name of the generated tar.gz helm package
  values_tag_yaml_path = "base.k8s.deployment.image.tag", // yaml Path of the image tag in the values.yaml files
  helm_chart_version = "v0.1.1"
)
```

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| srcs | yes | - | Chart source files. Must be a list of **bazel labels** (or a glob pattern) containing the path where the helm chart files and values are placed. Just one helm package should placed under `srcs` files. |
| image | false | - | Label referencing another bazel rule that implements [docker container image rule](https://github.com/bazelbuild/rules_docker#container_image-1). This attr is used to obtain the digest of the built docker image and use it as the docker image tag of the application. |
| image_tag | false | - | Fixed image tag value that will be used in the deployment. It can contain a string (e.g `master`), or the key of a make variable if is included in curly braces (e.g {GIT_COMMIT}). If a make variable format is used, the variable has to be provided through the `--define` method. Note: This attribute is an alternative to the `image` attribute if you want to provide a "fixed" image tag of your application instead of using a bazel rule to generate the docker image of your app. If you specify both, `image` attribute has preferenece.  |
| package_name | true | - | The name of the helm package. It must be the same name that was defined in the Chart.yaml |
| helm_chart_version | false | `1.0.0` | Used to replace the Chart.yaml version of the helm package. It has to be defined following the [semver](https://semver.org/) nomenclature. Support make variables if the attribute is placed inside curly braces (e.g {HELM_VERSION})|
| image_repository | false | - | The url of the docker registry where the docker image is stored. This is usually where the `image.repository` points to in the values.yaml file |
| values_repo_yaml_path | false | `image.repository` | The yaml path (expressed in dot notation) of values.yaml where the key of the image repository is defined in the values.yaml. |
| values_tag_yaml_path | false | `image.tag` | The yaml path (expressed in dot notation) of values.yaml where the key of the image tag is defined in the values.yaml |


#### Use of make_variables
`image_tag` and `helm_chart_version` attributes support make variables. Make variables are provided to bazel through the `--define` argument.
To enable make variables, string values have to be inside curly braces `image_tag="{GIT_SHA}"`.

```
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
```
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
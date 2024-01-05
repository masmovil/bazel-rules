<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="helm_push"></a>

## helm_push

<pre>
helm_push(<a href="#helm_push-name">name</a>, <a href="#helm_push-chart">chart</a>, <a href="#helm_push-repository_url">repository_url</a>)
</pre>

Publish a helm chart produced by `helm_chart` rule to a remote registry.

To load the rule use:
```starlark
load("//helm:defs.bzl", "helm_push")
```

This rule builds an executable. Use `run` instead of `build` to be publish the chart.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="helm_push-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="helm_push-chart"></a>chart |  The packaged chart archive to be published. It can be a reference to a `helm_chart` rule or a reference to a helm archived file   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="helm_push-repository_url"></a>repository_url |  The remote url of the registry. Avoid adding the helm chart name in the url.   | String | required |  |



<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="helm_lint_test"></a>

## helm_lint_test

<pre>
helm_lint_test(<a href="#helm_lint_test-name">name</a>, <a href="#helm_lint_test-chart">chart</a>)
</pre>

Test rule to verify that a helm chart is well-formed.

To load the rule use:
```starlark
load("//helm:defs.bzl", "helm_lint_test")
```

It uses `helm lint` command to perform the linting.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="helm_lint_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="helm_lint_test-chart"></a>chart |  The chart to lint. It could be either a reference to a `helm_chart` rule that produces an archived chart as a default output or a reference to an archived chart.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |



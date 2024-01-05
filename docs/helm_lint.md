<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="helm_lint_test"></a>

## helm_lint_test

<pre>
helm_lint_test(<a href="#helm_lint_test-name">name</a>, <a href="#helm_lint_test-chart">chart</a>)
</pre>

Macro function to test that a helm chart is well-formed.

To load the rule use:
```starlark
load("//helm:defs.bzl", "helm_lint_test")
```

It uses `helm lint` command to perform the linting.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="helm_lint_test-name"></a>name |  The name of the rule   |  none |
| <a id="helm_lint_test-chart"></a>chart |  The chart to lint<br><br>It could be a reference to a `helm_chart` rule that produces an archived chart as a default output. It can also be a reference to an archived chart.   |  none |



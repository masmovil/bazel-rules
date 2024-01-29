load("@bazel_skylib//rules:write_file.bzl", "write_file")

def helm_lint_test(name, chart):
    """Macro function to test that a helm chart is well-formed.

    To load the rule use:
    ```starlark
    load("//helm:defs.bzl", "helm_lint_test")
    ```

    It uses `helm lint` command to perform the linting.

    Args:

        name: The name of the rule

        chart: The chart to lint

            It could be a reference to a `helm_chart` rule that produces an archived chart as a default output.
            It can also be a reference to an archived chart.

    """

    shell_file_name = "_%s_helm_lint" % name

    write_file(
        name = shell_file_name,
        out = "%s_helm_lint.sh" % name,
        content = [
            # helm lint path
            "$1 lint $2",
        ],
    )

    native.sh_test(
        name = name,
        srcs = [":" + shell_file_name],
        data = [chart, "@helm_toolchains//:resolved_toolchain"],
        # provided through args to allow path extension
        args = ["$(HELM_BIN)", "$(rootpath %s)" % chart],
        toolchains = ["@helm_toolchains//:resolved_toolchain"],
        tags = ["manual"],
    )

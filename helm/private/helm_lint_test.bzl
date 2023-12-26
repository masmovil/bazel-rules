load("@bazel_skylib//rules:write_file.bzl", "write_file")

def helm_lint_test(name, chart):
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
    )

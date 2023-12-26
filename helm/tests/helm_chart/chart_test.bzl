load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

def add_prefix_to_paths(prefix, files_path):
  return [paths.join(prefix, path) for path in files_path]

def compare_to_yaml_file_test(name, chart_name, file_name, expected_content, chart_dep):
    sh_test_rulename = "_%s_diff" % name
    expected_content_rulename = "_%s_expected" % name
    test_rulename =  "%s_diff" % name

    write_file(
        name = expected_content_rulename,
        out = "%s_expected.yaml" % name,
        content = [expected_content],
    )

    write_file(
        name = sh_test_rulename,
        out = "%s_diff.sh" % name,
        content = [
            "diff <($1 -P 'sort_keys(..)' -o=props $2) <($1 -P 'sort_keys(..)' -o=props $3)"
        ],
    )

    native.sh_test(
        name = test_rulename,
        srcs = [sh_test_rulename],
        data = ["@yq_toolchains//:resolved_toolchain", expected_content_rulename, chart_dep],
        args = [
            "$(YQ_BIN)",
            "$(location %s)/%s/%s" % (chart_dep, chart_name, file_name),
            "$(location %s)" % expected_content_rulename
        ],
        toolchains = ["@yq_toolchains//:resolved_toolchain"],
    )

    return  test_rulename

def chart_test(name, chart, chart_name, prefix_srcs, expected_files, expected_values="", expected_manifest=""):
    unpacked_chart_rule_name = "%s_unpacked" % name

    native.genrule(
        name = unpacked_chart_rule_name,
        outs = ["%s_out_dir" % unpacked_chart_rule_name],
        tools = [chart],
        cmd_bash = "mkdir -p $@ && tar -xvf $(location %s) -C $@" % chart,
    )

    tests = []

    if expected_values != "":
        tests += [compare_to_yaml_file_test(
            name = "%s_values_test_diff" % name,
            chart_name = chart_name,
            file_name = "values.yaml",
            expected_content = expected_values,
            chart_dep = unpacked_chart_rule_name,
        )]

    if expected_manifest != "":
        tests += [compare_to_yaml_file_test(
            name = "%s_manifest_test_diff" % name,
            chart_name = chart_name,
            file_name = "Chart.yaml",
            expected_content = expected_manifest,
            chart_dep = unpacked_chart_rule_name,
        )]

    sh_diff_rulename = "_%s_src_diff.sh" % name

    write_file(
        name = sh_diff_rulename,
        out = "%s_src_diff.sh" % name,
        content = [
            "diff $1 $2"
        ],
    )

    filtered_expected_files = [file_path for file_path in expected_files if not file_path.endswith("Chart.yaml") and not file_path.endswith("values.yaml")]

    for expected_file in filtered_expected_files:
        expected_file_name = paths.basename(expected_file)
        src_diff_test_rulename = "%s_%s_src_diff_test" % (name, expected_file_name)
        native.sh_test(
            name = src_diff_test_rulename,
            srcs = [sh_diff_rulename],
            data = [expected_file, unpacked_chart_rule_name],
            args = [
                "$(location %s)/%s/%s" % (unpacked_chart_rule_name, chart_name, paths.relativize(expected_file, prefix_srcs)),
                "$(location %s)" % expected_file,
            ]
        )
        tests += [src_diff_test_rulename]

    native.test_suite(
        name = name,
        tests = tests,
    )

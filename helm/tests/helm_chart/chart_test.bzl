load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

def add_prefix_to_paths(prefix, files_path):
  return [paths.join(prefix, path) for path in files_path]

def compare_to_yaml_file_test(name, yaml_file_path, explicit_yaml_to_compare, chart):
    sh_test_rulename = "_%s_diff" % name
    expected_yaml_rulename = "_%s_expected" % name
    test_rulename =  "%s_diff" % name

    write_file(
        name = expected_yaml_rulename,
        out = "%s_expected.yaml" % name,
        content = [explicit_yaml_to_compare],
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
        data = ["@yq_toolchains//:resolved_toolchain", expected_yaml_rulename, chart],
        args = [
            "$(YQ_BIN)",
            yaml_file_path,
            "$(location %s)" % expected_yaml_rulename
        ],
        toolchains = ["@yq_toolchains//:resolved_toolchain"],
    )

    return  test_rulename

def chart_test(name, chart, chart_name, prefix_srcs, expected_files, expected_values="", expected_manifest="", expected_deps=[]):
    print("EXPECTED FILES: %s", expected_files)

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
            yaml_file_path = "$(location %s)/%s/values.yaml" % (unpacked_chart_rule_name, chart_name),
            explicit_yaml_to_compare = expected_values,
            chart = unpacked_chart_rule_name,
        )]

    if expected_manifest != "":
        tests += [compare_to_yaml_file_test(
            name = "%s_manifest_test_diff" % name,
            yaml_file_path = "$(location %s)/%s/Chart.yaml" % (unpacked_chart_rule_name, chart_name),
            explicit_yaml_to_compare = expected_manifest,
            chart = unpacked_chart_rule_name,
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

    for i, expected_file in enumerate(filtered_expected_files):
        expected_file_name = paths.basename(expected_file)
        src_diff_test_rulename = "%s_%s_src_diff_test_%d" % (name, expected_file_name, i)
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

    for dep in expected_deps:
        dep_name = dep["name"]
        dep_values = dep["expected_values"]
        dep_manifest = dep["expected_manifest"]

        if dep_values:
            tests += [
                compare_to_yaml_file_test(
                    name = "%s_%s_values_dep_test_diff" % (dep_name, name),
                    yaml_file_path = "$(location %s)/%s/charts/%s/values.yaml" % (unpacked_chart_rule_name, chart_name, dep_name),
                    explicit_yaml_to_compare = dep_values,
                    chart = unpacked_chart_rule_name,
                )
            ]

        if dep_manifest:
            tests += [
                compare_to_yaml_file_test(
                    name = "%s_%s_values_dep_test_diff" % (dep_name, name),
                    yaml_file_path = "$(location %s)/%s/charts/%s/Chart.yaml" % (unpacked_chart_rule_name, chart_name, dep_name),
                    explicit_yaml_to_compare = dep_manifest,
                    chart = unpacked_chart_rule_name,
                )
            ]


    native.test_suite(
        name = name,
        tests = tests,
    )

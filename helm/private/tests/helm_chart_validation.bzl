load(
    "@com_github_masmovil_bazel_rules//helm:def.bzl",
    "ChartInfo"
)

def _helm_chart_validation_test_impl(ctx):
  """Rule for instantiating helm_chart.sh.template for a given target."""
  exe = ctx.outputs.executable
  chart = ctx.file.chart
  debug = ctx.attr.debug
  chart_info = ctx.attr.chart[ChartInfo]
  chart_name = chart_info.chart_name
  chart_version = chart_info.chart_version
  ctx.actions.expand_template(output = exe,
                              template = ctx.file._script,
                              is_executable = True,
                              substitutions = {
                                "%CHART%": chart.short_path,
                                "%CHART_NAME%": chart_name,
                                "%DEBUG%": str(debug),
                                "%CHART_VERSION%": chart_version,
                                "%EXPECTED_FILES%": "\n".join(["%s" % file for file in ctx.attr.expected_chart_files]),
                                "%EXPECTED_VALUES%": ctx.attr.expected_values,
                                "%EXPECTED_DEPS%": "\n".join(["%s" % dep for dep in ctx.attr.expected_chart_deps]),
                              })
  # This is needed to make sure the output file of myrule is visible to the
  # resulting instantiated script.
  return [DefaultInfo(runfiles=ctx.runfiles(files=[chart]))]

helm_chart_validation_test = rule(
    implementation = _helm_chart_validation_test_impl,
    attrs = {"chart": attr.label(allow_single_file=True),
             "expected_chart_files": attr.string_list(mandatory = True),
             "expected_chart_deps": attr.string_list(mandatory = False),
             "expected_values": attr.string(mandatory = False),
             "debug": attr.bool(default=False),
             "_script": attr.label(
                                   allow_single_file=True,
                                   default=Label("@com_github_masmovil_bazel_rules//helm/private/tests:helm_chart_validation_template")
                                  )
            },
    test = True,
)

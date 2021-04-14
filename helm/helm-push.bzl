load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")

def _helm_push_impl(ctx):
    """Push a helm chart to a helm repository
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """

    chart = ctx.file.chart
    # get chart museum basic auth credentials
    user = get_make_value_or_default(ctx, ctx.attr.repository_username)
    user_pass = get_make_value_or_default(ctx, ctx.attr.repository_password)
    repo_url = get_make_value_or_default(ctx, ctx.attr.repository_url)

    if not repo_url.endswith("/"):
      repo_url += "/"
    if ctx.attr.repo_type == "museum":
      repo_url += "api/charts"
      curl_arg = "--data-binary"
      chart_path = "@" + chart.short_path
    elif ctx.attr.repo_type == "nexus":
      curl_arg = "--upload-file"
      chart_path = chart.short_path

    # Generates the exec bash file with the provided substitutions
    exec_file = write_sh(
      ctx,
      "curl_bash",
      """
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" {CURL_ARG} "{CHART_PATH}" -u {USERNAME}:{PASSWORD} {REPOSITORY_URL})
        echo "http post response code: "$HTTP_CODE

        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "409" ]; then
          echo "exit 0"
          exit 0
        else
          echo "exit 1"
          exit 1
        fi
      """,
      {
        "{CHART_PATH}": chart_path,
        "{USERNAME}": user,
        "{PASSWORD}": user_pass,
        "{REPOSITORY_URL}": repo_url,
        "{CURL_ARG}": curl_arg,
      }
    )

    runfiles = ctx.runfiles(files = [chart])

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_push = rule(
    implementation = _helm_push_impl,
    attrs = {
      "chart": attr.label(allow_single_file = True, mandatory = True),
      "repository_name": attr.string(mandatory = True),
      "repository_url": attr.string(mandatory = True),
      "repository_username": attr.string(mandatory = True),
      "repository_password": attr.string(mandatory = True),
      "repo_type": attr.string(values = ["museum", "nexus"], default = "museum")
    },
    doc = "Push helm chart to a helm repository",
    toolchains = [],
    executable = True,
)

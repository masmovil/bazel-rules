# Generates a bash file from string template replacing
# placeholders with provided substition values
def write_sh(ctx, sh_filename, tpl, substitutions = {}, is_executable = True):
  tmp_sh = ctx.actions.declare_file(ctx.label.name + "_tmp_" + sh_filename)
  sh_file = ctx.actions.declare_file(ctx.label.name + "_" + sh_filename)

  # generate a new file containing the bash template (with placeholders to replace)
  ctx.actions.write(tmp_sh, tpl)

  # replace the placeholders of the bash template with the provided substitutions
  ctx.actions.expand_template(
    template = tmp_sh,
    output = sh_file,
    is_executable = is_executable,
    substitutions = substitutions
  )

  return sh_file


# Check if the provided variable is a make_variable key
# and return the make variable value. If it is not a
# make_variable key, returns the value itself.
def get_make_value_or_default(ctx, var):
    if var.startswith('{') and var.endswith('}'):
      key = var[1:len(var) - 1]
      return ctx.var.get(key)
    else:
      return var
# bazel rules

![Build Status](https://github.com/masmovil/bazel-rules/actions/workflows/integration-tests.yaml/badge.svg)

This repository contains Bazel rules to:
- Manipulate and install kubernetes Helm charts
- Perform some k8s and gcp operational tasks
- Encrypt/decrypt secrets using mozilla sops.

## Documentation

### Getting started

In your Bazel `WORKSPACE` file, after the [rules_docker](https://github.com/bazelbuild/rules_docker#setup), add this repository as a dependency and invoke repositories helper method:

```python
git_repository(
    name = "com_github_masmovil_bazel_rules",
    commit = "commit-ref",
    remote = "https://github.com/masmovil/bazel-rules.git",
)

load(
    "@com_github_masmovil_bazel_rules//repositories:repositories.bzl",
    mm_repositories = "repositories",
)
mm_repositories()
```

### Helm rules

[Helm rules documentation](helm/README.md)

### Sops rules

[Sops rules documentation](sops/README.md)

## K8s rules

[k8s rules documentation](k8s/README.md)

## GCS rules

[gcs rules documentation](gcs/README.md)

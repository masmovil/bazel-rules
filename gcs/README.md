## GCS rules

Import in your `BUILD.bazel`

```python
load("@com_github_masmovil_bazel_rules//gcs:gcs.bzl", "gcs_upload")

```

**Gcloud SDK** is required in the system PATH.

### gcs_upload

`gcs_upload` is used to upload a single file to a Google Cloud Storage bucket

Example of use:
```python
gcs_upload(
    name = "push",
    src = ":file",
    destination = "gs://my-bucket/file.zip"
)
```


The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| src | yes | - | Source file label |
| destination | yes | - | Destination path in GCS (in form of`gs://mybucket/file`) It supports the use of `stamp_variables`. |

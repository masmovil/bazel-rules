<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="gcs_upload"></a>

## gcs_upload

<pre>
load("@masmovil_bazel_rules//gcs/private:gcs_upload.bzl", "gcs_upload")

gcs_upload(<a href="#gcs_upload-name">name</a>, <a href="#gcs_upload-src">src</a>, <a href="#gcs_upload-destination">destination</a>)
</pre>

Rule used to upload a single file to a Google Cloud Storage bucket

To load the rule use:
```starlark
load("//gcs:defs.bzl", "gcs_upload")
```

Example of use:

```starlark
load("//gcs:defs.bzl", "gcs_upload")

gcs_upload(
    name = "push",
    src = ":file",
    destination = "gs://my-bucket/file.zip"
)
```

This rule builds an executable. Use `run` instead of `build` to upload the file.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="gcs_upload-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="gcs_upload-src"></a>src |  Source file to upload   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="gcs_upload-destination"></a>destination |  Google storage destination url. Example: gs://my-bucket/file   | String | required |  |



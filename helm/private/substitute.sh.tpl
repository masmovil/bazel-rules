#!/bin/bash

{yq} --from-file {expression} {values} > {out}

export IMAGE_DIGEST={image_digest_expr}

if [ ! -z "${IMAGE_DIGEST}" ]; then
    echo "Digest: "$IMAGE_DIGEST
    {yq} -i '{image_tag_path} = strenv(IMAGE_DIGEST)' {out};
fi;

export IMAGE_REPO={image_repo_expr}

if [ ! -z "${IMAGE_REPO}" ]; then
    {yq} -i '{image_repo_path} = strenv(IMAGE_REPO)' {out};
fi;

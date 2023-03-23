package main

import (
	"fmt"
	"io/ioutil"

	"github.com/pkg/errors"
	log "github.com/sirupsen/logrus"
	"helm.sh/helm/pkg/strvals"
	"helm.sh/helm/v3/pkg/chartutil"
)

type Image struct {
	Repository 	string
	Tag 		string
}

func parseValuesFromPathString(values map[string]string) (chartutil.Values, error) {
	var strValue string

	for key, value := range values {
		if (strValue != "") {
			strValue += ","
		}

		strValue += fmt.Sprintf("%s=%s", key, value)
	}

	log.Debugf("Values to convert from strValues: %v", values)
	log.Debugf("String values: %s", strValue)

	if strValue != "" {
		parsedValues, err := strvals.Parse(strValue)

		if err != nil {
			return nil, errors.Wrapf(err, "Error trying to parse image values %v into a yaml object", parsedValues)
		}

		return parsedValues, nil
	} else {
		return chartutil.Values{}, nil
	}
}

func getImage(digestFilePath string, repo string, tag string) (*Image, error) {
	var (
		imageTag 		string
		imageRepository string
		err 			error
	)

	if digestFilePath != "" {
		imageTag, err = extractImageDigest(digestFilePath)

		if err != nil {
			return nil, errors.Wrapf(err, "Error extracting image digest from digest file %s", digestFilePath)
		}

		imageRepository = repo + "@sha256"
	} else {
		imageRepository = repo
		imageTag = tag
	}

	return &Image{
		Repository: imageRepository,
		Tag: imageTag,
	}, nil
}

func getImageValues(repoPath string, tagPath string, digestFilePath string, repo string, tag string) (chartutil.Values, error) {
	image, err := getImage(digestFilePath, repo, tag)

	if err != nil {
		return nil, err
	}

	imageMap := map[string]string{}

	if image.Repository != "" {
		imageMap[repoPath] = image.Repository
	}

	if image.Tag != "" {
		imageMap[tagPath] = image.Tag
	}

	return parseValuesFromPathString(imageMap)
}


var extractImageDigest = func(digestPath string) (string, error) {
	digestFileContent, err := ioutil.ReadFile(digestPath)

	if err != nil {
		return "", err
	}

	return string(digestFileContent)[7:], nil
}

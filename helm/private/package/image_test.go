package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"helm.sh/helm/v3/pkg/chartutil"
)

type ImageTestSuite struct {
	suite.Suite
}


func TestImageTestSuite(t *testing.T) {
	suite.Run(t, &ImageTestSuite{})
}

var mockDigestValue string = "testdatashasum"

func getImageDigestMock (path string) (string, error) {
	return mockDigestValue, nil
}

func (s *ImageTestSuite) TestParseValuesFromStrVal() {
	type TestData struct {
		StrValues map[string]string
		Expected chartutil.Values
	}

	for _, testData := range []TestData{
		TestData{
			StrValues: map[string]string{
				"val1": "test1",
				"nested.val2": "test2",
			},
			Expected: map[string]interface{}{
				"val1": "test1",
				"nested": map[string]interface{}{
					"val2": "test2",
				},
			},
		},
		TestData{
			StrValues: map[string]string{
				"somekey": "deep1",
				"d.somekey2.nestedtwicekey": "deep3",
				"d.somekey3": "deep2",
			},
			Expected: map[string]interface{}{
				"somekey": "deep1",
				"d": map[string]interface{}{
					"somekey3": "deep2",
					"somekey2": map[string]interface{}{
						"nestedtwicekey": "deep3",
					},
				},
			},
		},
	} {
		result, err := parseValuesFromPathString(testData.StrValues)

		assert.NoError(s.T(), err)

		assert.Equal(s.T(), testData.Expected, result)
	}
}

func (s *ImageTestSuite) TestGetImageValues() {
	type TestImageData struct {
		RepoPath string
		DigPath string
		TagPath string
		Repo string
		Tag string
	}

	type TestData struct {
		Image TestImageData
		Expected chartutil.Values
	}

	origDigestImp := extractImageDigest

	extractImageDigest = getImageDigestMock

	for _, testData := range []TestData{
		TestData{
			Image: TestImageData{
				RepoPath: "key1.key2.repo",
				TagPath: "key1.key2.tag",
				DigPath: "randompath",
				Repo: "randomrepo",
				Tag: "randomtag",
			},
			Expected: map[string]interface{}{
				"key1": map[string]interface{}{
					"key2": map[string]interface{}{
						"repo": "randomrepo@sha256",
						"tag": mockDigestValue,
					},
				},
			},
		},
		TestData{
			Image: TestImageData{
				RepoPath: "key1.repo",
				TagPath: "key1.key2.tag",
				DigPath: "randompath",
				Repo: "randomrepo",
			},
			Expected: map[string]interface{}{
				"key1": map[string]interface{}{
					"repo": "randomrepo@sha256",
					"key2": map[string]interface{}{
						"tag": mockDigestValue,
					},
				},
			},
		},
		TestData{
			Image: TestImageData{
				RepoPath: "key1.repo",
				TagPath: "key1.tag",
				DigPath: "",
				Repo: "randomrepo",
				Tag: "randomtag",
			},
			Expected: map[string]interface{}{
				"key1": map[string]interface{}{
					"repo": "randomrepo",
					"tag": "randomtag",
				},
			},
		},
		TestData{
			Image: TestImageData{
				RepoPath: "repo",
				TagPath: "tag",
				DigPath: "",
				Repo: "randomrepo",
				Tag: "randomtag",
			},
			Expected: map[string]interface{}{
				"repo": "randomrepo",
				"tag": "randomtag",
			},
		},
		TestData{
			Image: TestImageData{
				RepoPath: "repo",
				TagPath: "tag",
				DigPath: "",
				Repo: "randomrepo",
				Tag: "",
			},
			Expected: map[string]interface{}{
				"repo": "randomrepo",
			},
		},
		TestData{
			Image: TestImageData{
				RepoPath: "repo",
				TagPath: "tag",
				DigPath: "",
				Repo: "",
				Tag: "",
			},
			Expected: map[string]interface{}{},
		},
	} {
		img := testData.Image

		values, err := getImageValues(img.RepoPath, img.TagPath, img.DigPath, img.Repo, img.Tag)

		assert.NoError(s.T(), err)

		assert.Equal(s.T(), testData.Expected, values)
	}

	extractImageDigest = origDigestImp
}

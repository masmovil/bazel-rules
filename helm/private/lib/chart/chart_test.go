package chart

import (
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"helm.sh/helm/v3/pkg/chart"
	"helm.sh/helm/v3/pkg/chartutil"
)

type ChartTestSuite struct {
	suite.Suite
}

func TestChartTestSuite(t *testing.T) {
	suite.Run(t, &ChartTestSuite{})
}

func readFsStub (path string) ([]byte, error) {
	return []byte("some bytes"), nil
}

func (s *ChartTestSuite) TestAddChartTemplates() {
	readFsOrigImp := readFileFs

	type TestDataTemplate struct {
		Inputs []string
		Expected []string
	}

	for _, testData := range []TestDataTemplate {
		TestDataTemplate{
			Inputs: []string{"deployment.yaml"},
			Expected: []string{"deployment.yaml"},
		},
		TestDataTemplate{
			Inputs: []string{"template/deployment.yaml", "templates/deploy.yaml", "service.yaml" },
			Expected: []string{"deployment.yaml", "deploy.yaml", "service.yaml"},
		},
		TestDataTemplate{
			Inputs: []string{"subdir1/sudir2/ingress.yaml"},
			Expected: []string{"ingress.yaml"},
		},
		TestDataTemplate{
			Inputs: []string{},
			Expected: []string{},
		},
	} {

		testChart := NewHelmChart(ChartOptions{Name: "test", Version: "v1.0.0", Templates: testData.Inputs })

		readFileFs = readFsStub

		err := testChart.LoadFromDeclaration()

		assert.NoError(s.T(), err)

		assert.Equal(s.T(), len(testData.Expected), len(testChart.Chart.Templates))

		bytes, _ := readFsStub("")

		for _, template := range testData.Expected {
			assert.Contains(s.T(), testChart.Chart.Templates, &chart.File{Name: filepath.Join("templates", template), Data: bytes})
		}
	}

	readFileFs = readFsOrigImp
}

func (s *ChartTestSuite) TestAddChartFiles() {
	readFsOrigImp := readFileFs

	for _, testData := range [][]string {
		[]string{"README.md"},
		[]string{"subdir/README.md", "subdir/readme.md"},
		[]string{"subdir1/subdir2/license.txt"},
		[]string{},
	} {
		testChart := NewHelmChart(ChartOptions{Name: "test", Version: "v1.0.1", Files: testData })

		readFileFs = readFsStub

		err := testChart.LoadFromDeclaration()

		assert.NoError(s.T(), err)

		assert.Equal(s.T(), len(testData), len(testChart.Chart.Files))

		bytes, _ := readFsStub("")

		for _, file := range testData {
			assert.Contains(s.T(), testChart.Chart.Files, &chart.File{Name: file, Data: bytes})
		}
	}

	readFileFs = readFsOrigImp
}

func (s *ChartTestSuite) TestAddValues() {
	type TestDataValues struct {
		InitialChartValues chartutil.Values
		Values chartutil.Values
		Expected chartutil.Values
	}

	for _, testData := range []TestDataValues{
		TestDataValues{
			InitialChartValues: chartutil.Values{},
			Values: chartutil.Values{
				"key1": "val1",
			},
			Expected: chartutil.Values{
				"key1": "val1",
			},
		},
		TestDataValues{
			InitialChartValues: chartutil.Values{
				"key1": "data1",
				"key2": "data2",
			},
			Values: chartutil.Values{},
			Expected: chartutil.Values{
				"key1": "data1",
				"key2": "data2",
			},
		},
		TestDataValues{
			InitialChartValues: chartutil.Values{
				"key1": "data1",
				"key2": "data2",
			},
			Values: chartutil.Values{
				"key1": "overridedvalue",
			},
			Expected: chartutil.Values{
				"key1": "overridedvalue",
				"key2": "data2",
			},
		},
	} {
		testChart := NewHelmChart(ChartOptions{Name: "test", Version: "v1.0.1"})

		err := testChart.LoadFromDeclaration()

		assert.NoError(s.T(), err)

		if len(testData.InitialChartValues) > 0 {
			testChart.Chart.Values = testData.InitialChartValues
		}

		err = testChart.AddValues(testData.Values)

		assert.NoError(s.T(), err)

		expectedParsed, err := testData.Expected.YAML()

		assert.NoError(s.T(), err)

		assert.Contains(s.T(), testChart.Chart.Raw, &chart.File{Name: "values.yaml", Data: []byte(expectedParsed)})
	}
}

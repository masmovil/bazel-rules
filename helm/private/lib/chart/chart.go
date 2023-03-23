package chart

import (
	"io/ioutil"
	"path/filepath"

	"github.com/pkg/errors"
	"helm.sh/helm/v3/pkg/chart"
	chartLoader "helm.sh/helm/v3/pkg/chart/loader"
	"helm.sh/helm/v3/pkg/chartutil"
)

type ChartOptions struct {
	Name            		string
	Version         		string
	AppVersion          	string
	ApiVersion          	string
	KubeVersion         	string
	Tags         			string
	Condition         		string
	Description         	string
	Values         			string
	Keywords         		[]string
	ValueFiles         		[]string
	Templates         		[]string
	Files         			[]string
	Deps                 	[]string
}

var readFileFs = func (path string) ([]byte, error) {
	return ioutil.ReadFile(path)
}

type HelmChart interface {
	LoadFromFs(path string) error
	LoadFromDeclaration() error
	Save(path string) (string, error)
	AddValues(values chartutil.Values) (error)
}

type helmChart struct {
	opts ChartOptions
	Chart *chart.Chart
}

// Factory method to instantiate a new HelmChart interface
func NewHelmChart(opts ChartOptions) helmChart {
	return helmChart{
		opts: opts,
		Chart: &chart.Chart{},
	}
}

// Load helm chart from disk src files.
// It takes care of loading chart values, templates, regular files, dependencies...
func (ch *helmChart) LoadFromFs(path string) error {
	loadedChart, err := chartLoader.Load(path)

	if err != nil {
		return errors.Wrapf(err, "Cannot load chart from disk path %s", path)
	}

	ch.Chart = loadedChart

	// err = compareChartMetadata(helmChart, ch.opts)

	if err != nil {
		return errors.Wrapf(err, "Chart metadata is not reconciliable")
	}

	return ch.loadChartData()
}

// Load helm chart from rule declaration. No Chart.yaml manifest exist in disk for this helm chart.
// It takes care of loading chart values, templates, regular files, dependencies...
func (ch *helmChart) LoadFromDeclaration() error {
	opts := ch.opts

	metadata := &chart.Metadata{
		Name: opts.Name,
		Description: opts.Description,
		Version: opts.Version,
		AppVersion: opts.AppVersion,
		APIVersion: opts.ApiVersion,
		KubeVersion: opts.KubeVersion,
		Tags: opts.Tags,
		Condition: opts.Condition,
		Keywords: opts.Keywords,
	}

	ch.Chart = &chart.Chart{
		Metadata: metadata,
		Templates: []*chart.File{},
		Values: map[string]interface{}{},
		Files: []*chart.File{},
	}

	return ch.loadChartData()
}

// Add values to helm chart.
// This method merge the provided values into helm chart object.
// After merge the values, it overrides the default values file with the new merged values.
func (ch *helmChart) AddValues(values chartutil.Values) error {
	mergedValues, err := chartutil.CoalesceValues(ch.Chart, values)

	if err != nil {
		return errors.Wrapf(err, "Error loading values into helm chart")
	}

	ch.Chart.Values = mergedValues

	serializedMergedValues, err := mergedValues.YAML()

	if err != nil {
		return errors.Wrapf(err, "Error serializing merged values into helm chart")
	}

	file := &chart.File{ Name: chartutil.ValuesfileName, Data: []byte(serializedMergedValues) }

	savedValues := false

	for i, raw := range ch.Chart.Raw {
		if raw.Name == "values.yaml" {
			ch.Chart.Raw[i] = file
			savedValues = true
		}
	}

	if !savedValues {
		ch.Chart.Raw = append(ch.Chart.Raw, file)
	}

	return nil
}

// Saves the chart data into a packaged targz helm chart on disk.
func (ch *helmChart) Save(path string) (string, error) {
	path, err := chartutil.Save(ch.Chart, path)

	if err != nil {
		return "", errors.Wrapf(err, "Error saving chart in output directory %s", path)
	}

	return path, err
}

func (ch *helmChart) readValues () ([]chartutil.Values, error){
	var mergedValues []chartutil.Values

	for _, valueFilePath := range ch.opts.ValueFiles {
		value, err := chartutil.ReadValuesFile(valueFilePath)

		if err != nil {
			return nil, errors.Wrapf(err, "Cannot read value file %s", valueFilePath)
		}

		mergedValues = append(mergedValues, value)
	}

	if ch.opts.Values != "" {
		explicitValues, err := chartutil.ReadValues([]byte(ch.opts.Values))

		if err != nil {
			return nil, errors.Wrapf(err, "Error reading explicit values defined in values helm_chart attributes")
		}

		mergedValues = append(mergedValues, explicitValues)
	}

	return mergedValues, nil
}

func (ch *helmChart) loadChartData() error {
	values, err := ch.readValues()

	if err != nil {
		return errors.Wrapf(err, "Error adding processed values to chart helm %v", values)
	}

	for _, val := range values {
		err = ch.AddValues(val)

		if err != nil {
			return errors.Wrapf(err, "Error adding processed values to helm chart %v", val)
		}
	}

	err = ch.loadTemplates(ch.opts.Templates)

	if err != nil {
		return errors.Wrapf(err, "Cannot add template files to the chart")
	}

	err = ch.loadFiles(ch.opts.Files)

	if err != nil {
		return errors.Wrapf(err, "Cannot add files to the chart")
	}

	return ch.loadDependencies()
}

func (ch *helmChart) loadTemplates(templates []string) error {
	var templateFiles []*chart.File

	for _, templatePath := range templates {
		template, err := readFileFs(templatePath)

		if err != nil {
			return err
		}

		templateFiles = append(templateFiles, &chart.File{
			Name: filepath.Join("templates", filepath.Base(templatePath)),
			Data: template,
		})
	}

	ch.Chart.Templates = append(ch.Chart.Templates, templateFiles...)

	return nil
}

func (ch *helmChart) loadFiles(files []string) error {
	var regularFiles = []*chart.File{}

	for _, path := range ch.opts.Files {
		fileData, err := readFileFs(path)

		if err != nil {
			return errors.Wrapf(err, "Could not open file %s from chart", path)
		}

		regularFiles = append(regularFiles, &chart.File{
			Name: path,
			Data: fileData,
		})
	}

	ch.Chart.Files = append(ch.Chart.Files, regularFiles...)

	return nil
}

func (ch *helmChart) loadDependencies() error {
	for _, depPath := range ch.opts.Deps {
		depChart, err := chartLoader.Load(depPath)

		if err != nil {
			return errors.Wrapf(err, "Cannot load chart dependency %s", depPath)
		}

		ch.Chart.AddDependency(depChart)
	}

	return nil
}

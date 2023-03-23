package main

import (
	"github.com/masmovil/mm-monorepo/helm/lib/chart"

	log "github.com/sirupsen/logrus"
)

func init() {
	log.SetFormatter(&log.TextFormatter{
		ForceColors:   true,
		FullTimestamp: true,
	})
}

func main() {
	var (
		err error
	)
	opts := parseFlags()

	helmChart := chart.NewHelmChart(opts.ChartOptions)

	if opts.ChartPath != "" {
		err = helmChart.LoadFromFs(opts.ChartPath)
	} else {
		err = helmChart.LoadFromDeclaration()
	}

	if err != nil {
		log.Fatalf("Error processing chart - %v", err)
	}

	imageValues, err := getImageValues(opts.ValuesRepoPath, opts.ValuesTagPath, opts.ImageDigestPath, opts.ImageRepository, opts.ImageTag)

	if err != nil {
		log.Fatalf("Error processing container image - %v", err)
	}

	if len(imageValues) > 0 {
		err = helmChart.AddValues(imageValues)

		if err != nil {
			log.Fatalf("Error saving image values in to chart values - %v", err)
		}
	}

	path, err := helmChart.Save(opts.Out)

	if err != nil {
		log.Fatalf("Error saving chart in output directory %s - %v", path, err)
	}

	log.Infof("Chart successfully saved in %s", path)
}

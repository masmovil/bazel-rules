package main

import (
	"os"

	log "github.com/sirupsen/logrus"
	flag "github.com/spf13/pflag"
)

type Options struct {
	Files       []string
	FileOutputs []string
	SopsConfig  string
	OutRootDir  string
	Debug       bool
}

func parseFlags() *Options {
	opts := &Options{}

	log.Debugf("Golang binary Args: %+v", os.Args)

	flag.BoolVar(&opts.Debug, "debug", false, "Debug flag")
	flag.StringVar(&opts.OutRootDir, "out_root_dir", "", "Path to root bazel out dir")
	flag.StringVar(&opts.SopsConfig, "sops_config", "", "Path to sops config file")
	flag.StringArrayVar(&opts.Files, "f", []string{}, "Source files to decrypt")
	flag.StringArrayVar(&opts.FileOutputs, "fo", []string{}, "File outputs where to put decrypt result")

	flag.Parse()

	log.Debugf("Options extracted from binary args: %+v", opts)

	return opts
}

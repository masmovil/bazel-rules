package main

import (
	"os"
	"path/filepath"

	log "github.com/sirupsen/logrus"
	decrypt "go.mozilla.org/sops/v3/decrypt"
)

func init() {
	log.SetFormatter(&log.TextFormatter{
		ForceColors:   true,
		FullTimestamp: true,
	})
}

func main() {
	opts := parseFlags()

	if opts.Debug {
		log.Print("Set log level to debug")
		log.SetLevel(log.DebugLevel)
	}

	for i, file := range opts.Files {
		ext := filepath.Ext(file)[1:]
		out := opts.FileOutputs[i]

		encData, err := os.ReadFile(file)
		if err != nil {
			log.Fatal("Error opening encrypted file: ", err)
		}

		decData, err := decrypt.Data(encData, ext)
		if err != nil {
			log.Fatal("Error opening encrypted file: ", err)
		}

		os.WriteFile(out, decData, 0644)
	}
}

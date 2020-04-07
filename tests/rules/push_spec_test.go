package test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type HelmRelease struct {
	Name        string
	Description string
	Version     string
	AppVersion  string
	ApiVersion  string
	Urls        []string
	Created     string
	Digest      string
}

// Test suite for testing push of helm charts to a chart museum registry
func TestChartPush(t *testing.T) {
	chartMuseumNamespace := "system-chartmuseum"

	var museumResponse map[string][]HelmRelease

	k8sOptions := k8s.NewKubectlOptions("", "", chartMuseumNamespace)

	pods := k8s.ListPods(t, k8sOptions, v1.ListOptions{
		LabelSelector: "app=chartmuseum",
	})

	tunnel := k8s.NewTunnel(k8sOptions, k8s.ResourceTypePod, pods[0].Name, 8080, 8080)

	tunnel.ForwardPort(t)

	var tunelEndpoint = tunnel.Endpoint()

	defer tunnel.Close()

	shell.RunCommand(t, shell.Command{
		Command:           "bazel",
		Args:              []string{"run", "//tests/charts/nginx:nginx_push"},
		WorkingDir:        ".",
		Env:               map[string]string{},
		OutputMaxLineSize: 1024,
	})

	shell.RunCommand(t, shell.Command{
		Command:           "bazel",
		Args:              []string{"run", "//tests/charts/nginx:nginx_push_no_slash"},
		WorkingDir:        ".",
		Env:               map[string]string{},
		OutputMaxLineSize: 1024,
	})

	req, err := http.NewRequest(http.MethodGet, fmt.Sprintf("http://%s/api/charts", tunelEndpoint), http.NoBody)

	if err != nil {
		t.Errorf("Error creating chart museum request object %s", err)
	}

	req.SetBasicAuth("test", "test")

	resp, err := http.DefaultClient.Do(req)

	if err != nil {
		t.Errorf("Error in chart museum http response %s", err)
	}

	defer resp.Body.Close()

	dec := json.NewDecoder(resp.Body)

	dec.DisallowUnknownFields()

	err = dec.Decode(&museumResponse)

	if err != nil {
		t.Errorf("Error decoding chart museum http response %s", err)
	}

	nginxRelease := museumResponse["nginx"]

	require.Len(t, museumResponse["nginx"], 2)

	var releaseV1, releaseV2 HelmRelease

	for _, r := range nginxRelease {
		if r.Version == "1.0.0" {
			releaseV1 = r
		} else if r.Version == "2.0.0" {
			releaseV2 = r
		}
	}

	require.Equal(t, releaseV1.Name, "nginx")
	require.Equal(t, releaseV2.Name, "nginx")
	require.Equal(t, releaseV1.Version, "1.0.0")
	require.Equal(t, releaseV2.Version, "2.0.0")

	// Clean up - Delete published charts from chartmuseum

	delReq1, err1 := http.NewRequest(http.MethodDelete, fmt.Sprintf("http://%s/api/charts/%s/%s", tunelEndpoint, releaseV1.Name, releaseV1.Version), http.NoBody)
	delReq2, err2 := http.NewRequest(http.MethodDelete, fmt.Sprintf("http://%s/api/charts/%s/%s", tunelEndpoint, releaseV1.Name, releaseV1.Version), http.NoBody)

	if err1 != nil {
		t.Errorf("Error deleting chart museum %s", err1)
	}

	if err2 != nil {
		t.Errorf("Error deleting chart museum %s", err2)
	}

	delReq1.SetBasicAuth("test", "test")
	delReq2.SetBasicAuth("test", "test")

	resp1, err1 := http.DefaultClient.Do(req)
	resp2, err2 := http.DefaultClient.Do(req)

	if err1 != nil {
		t.Errorf("Error in chart museum http response %s", err1)
	}

	if err2 != nil {
		t.Errorf("Error in chart museum http response %s", err2)
	}

	defer resp1.Body.Close()
	defer resp2.Body.Close()
}

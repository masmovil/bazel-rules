package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/require"
	api "k8s.io/api/core/v1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Test suite for testing release of chart basic package
func TestBasicChartRelease(t *testing.T) {
	var helmVersion string = "3"

	namespaceName := "test-nginx"
	releaseName := "test-nginx"

	k8sOptions := k8s.NewKubectlOptions("", "", namespaceName)

	k8s.CreateNamespace(t, k8sOptions, namespaceName)

	shell.RunCommand(t, shell.Command{
		Command:           "bazel",
		Args:              []string{"run", "//tests/charts/nginx:nginx_helm_release"},
		WorkingDir:        ".",
		Env:               map[string]string{},
		OutputMaxLineSize: 1024,
	})

	defer k8s.DeleteNamespace(t, k8sOptions, namespaceName)

	if helmVersion == "2" {
		defer helm.Delete(t, &helm.Options{
			KubectlOptions: k8sOptions,
			EnvVars: map[string]string{
				"TILLER_NAMESPACE": "tiller-system",
			},
		}, releaseName, true)
	}

	pods := k8s.ListPods(t, k8sOptions, v1.ListOptions{
		LabelSelector: "app=nginx",
	})

	require.Equal(t, len(pods), 1)

	podName := pods[0].Name

	k8s.WaitUntilPodAvailable(t, k8sOptions, podName, 10, 1*time.Second)

	pod := k8s.GetPod(t, k8sOptions, podName)

	require.Equal(t, pod.Status.Phase, api.PodRunning)
}

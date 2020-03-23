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
func TestChartReleaseWithDeps(t *testing.T) {
	t.Parallel()

	namespaceName := "test-nginx-with-deps"
	releaseName := "test-nginx-with-deps"

	k8sOptions := k8s.NewKubectlOptions("", "", namespaceName)

	k8s.CreateNamespace(t, k8sOptions, namespaceName)

	shell.RunCommand(t, shell.Command{
		Command:           "bazel",
		Args:              []string{"run", "//tests/charts/nginx-with-deps:nginx_helm_release_with_deps"},
		WorkingDir:        ".",
		Env:               map[string]string{},
		OutputMaxLineSize: 1024,
	})

	defer helm.Delete(t, &helm.Options{
		KubectlOptions: k8sOptions,
		EnvVars: map[string]string{
			"TILLER_NAMESPACE": "tiller-system",
		},
	}, releaseName, false)

	defer k8s.DeleteNamespace(t, k8sOptions, namespaceName)

	basePods := k8s.ListPods(t, k8sOptions, v1.ListOptions{
		LabelSelector: "app=nginx-with-deps",
	})
	depsPods := k8s.ListPods(t, k8sOptions, v1.ListOptions{
		LabelSelector: "app=nginx",
	})

	require.Equal(t, len(basePods), 1)
	require.Equal(t, len(depsPods), 1)

	basePodName := basePods[0].Name
	depsPodsName := depsPods[0].Name

	k8s.WaitUntilPodAvailable(t, k8sOptions, basePodName, 10, 1*time.Second)
	k8s.WaitUntilPodAvailable(t, k8sOptions, depsPodsName, 10, 1*time.Second)

	basePod := k8s.GetPod(t, k8sOptions, basePodName)
	depPod := k8s.GetPod(t, k8sOptions, depsPodsName)

	require.Equal(t, basePod.Status.Phase, api.PodRunning)
	require.Equal(t, depPod.Status.Phase, api.PodRunning)
}

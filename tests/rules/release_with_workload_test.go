package test

import (
	"testing"

	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/require"
	api "k8s.io/api/core/v1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Test suite for testing release of chart basic package
func TestChartReleaseWithWorkloadDep(t *testing.T) {
	namespaceName := "test-sa"
	saName := "default"

	k8sOptions := k8s.NewKubectlOptions("", "", namespaceName)

	shell.RunCommand(t, shell.Command{
		Command:           "bazel",
		Args:              []string{"run", "//tests/charts/nginx:nginx_helm_release_workload", "--spawn_strategy=standalone"},
		WorkingDir:        ".",
		Env:               map[string]string{},
		OutputMaxLineSize: 1024,
	})

	defer k8s.DeleteNamespace(t, k8sOptions, namespaceName)

	k8s.WaitUntilNumPodsCreated(t, k8sOptions,
		v1.ListOptions{
			LabelSelector: "testLabel=basic-nginx",
		},
		1,
		5,
		5*time.Second,
	)

	pods := k8s.ListPods(t, k8sOptions, v1.ListOptions{
		LabelSelector: "testLabel=basic-nginx",
	})

	require.Equal(t, len(pods), 1)

	podsName := pods[0].Name

	k8s.WaitUntilPodAvailable(t, k8sOptions, podsName, 10, 1*time.Second)

	pod := k8s.GetPod(t, k8sOptions, podsName)

	require.Equal(t, pod.Status.Phase, api.PodRunning)

	sa := k8s.GetServiceAccount(t, k8sOptions, saName)

	require.Equal(t, sa.Name, saName)
	require.Equal(t, sa.GetAnnotations()["iam.gke.io/gcp-service-account"], "test@test.iam.gserviceaccount.com")
}

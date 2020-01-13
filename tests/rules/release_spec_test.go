package test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/shell"
)

// Test suite for testing release of chart basic package
func TestBasicChartRelease(t *testing.T) {
	t.Parallel()

	namespaceName := "test-nginx"
	releaseName := "test-nginx"

	// Setup the kubectl config and context. Here we choose to use the defaults, which is:
	// - HOME/.kube/config for the kubectl config file
	// - Current context of the kubectl config file
	// - Random namespace
	options := k8s.NewKubectlOptions("", "", namespaceName)

	k8s.CreateNamespace(t, options, namespaceName)

	shell.RunCommand(t, shell.Command{
		"bazel",
		[]string{"run", "//tests/charts/nginx:nginx_helm_release"},
		".",
		map[string]string{},
		1024,
	})

	defer helm.Delete(t, &helm.Options{}, releaseName, true)

	defer k8s.DeleteNamespace(t, options, namespaceName)

	pod := k8s.GetPod(t, options, "test-nginx")
	require.Equal(t, pod.Name, "test-nginx")
}

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
)

// Test suite for testing release of chart basic package
func TestChartPackageImageTagMakeVar(t *testing.T) {
	chartTarPackagePath := "bazel-bin/tests/charts/nginx/nginx.tgz"
	chartPackageRootPath := "nginx"
	relativeChartPackageRootPath := "../../" + chartPackageRootPath

	image_repository := "nginx"
	imageTag := "nginxTestImageTag"

	shell.RunCommand(t, shell.Command{
		Command:    "bazel",
		Args:       []string{"build", "//tests/charts/nginx:nginx_chart_make", "--define", "TEST_IMAGE_TAG=" + imageTag, "--spawn_strategy=standalone"},
		WorkingDir: ".",
		Env:        map[string]string{},
	})

	shell.RunCommand(t, shell.Command{
		Command:    "tar",
		Args:       []string{"-xzf", chartTarPackagePath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	defer shell.RunCommand(t, shell.Command{
		Command:    "rm",
		Args:       []string{"-f", chartTarPackagePath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	defer shell.RunCommand(t, shell.Command{
		Command:    "rm",
		Args:       []string{"-rf", chartPackageRootPath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	output := helm.RenderTemplate(t, &helm.Options{
		ValuesFiles: []string{
			relativeChartPackageRootPath + "/values.yaml",
		},
	}, relativeChartPackageRootPath, "nginx", []string{"templates/deployment.yaml"})

	var deployment appsv1.Deployment
	helm.UnmarshalK8SYaml(t, output, &deployment)

	require.Equal(t, deployment.Spec.Template.Spec.Containers[0].Image, image_repository+":"+imageTag)

}

func TestChartPackageChartVersionMakeVar(t *testing.T) {
	chartVersion := "0.0.2"
	chartTarPackagePath := "bazel-bin/tests/charts/nginx/nginx.tgz"
	chartPackageRootPath := "nginx"
	relativeChartPackageRootPath := "../../" + chartPackageRootPath

	shell.RunCommand(t, shell.Command{
		Command:    "bazel",
		Args:       []string{"build", "//tests/charts/nginx:nginx_chart_make_version", "--define", "TEST_VERSION=" + chartVersion, "--spawn_strategy=standalone"},
		WorkingDir: ".",
		Env:        map[string]string{},
	})

	shell.RunCommand(t, shell.Command{
		Command:    "tar",
		Args:       []string{"-xzf", chartTarPackagePath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	defer shell.RunCommand(t, shell.Command{
		Command:    "rm",
		Args:       []string{"-f", chartTarPackagePath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	defer shell.RunCommand(t, shell.Command{
		Command:    "rm",
		Args:       []string{"-rf", chartPackageRootPath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	output := helm.RenderTemplate(t, &helm.Options{
		ValuesFiles: []string{
			relativeChartPackageRootPath + "/values.yaml",
		},
	}, relativeChartPackageRootPath, "nginx", []string{"templates/deployment.yaml"})

	var deployment appsv1.Deployment
	helm.UnmarshalK8SYaml(t, output, &deployment)

	require.Equal(t, deployment.ObjectMeta.Labels["version"], chartVersion)
	require.Equal(t, deployment.Spec.Template.Spec.Containers[0].Image, "nginx:nginx")
}

func TestChartPackageNoImageNoTag(t *testing.T) {
	chartTarPackagePath := "bazel-bin/tests/charts/nginx/nginx.tgz"
	chartPackageRootPath := "nginx"
	relativeChartPackageRootPath := "../../" + chartPackageRootPath

	shell.RunCommand(t, shell.Command{
		Command:    "bazel",
		Args:       []string{"build", "//tests/charts/nginx:nginx_chart_no_image", "--spawn_strategy=standalone"},
		WorkingDir: ".",
		Env:        map[string]string{},
	})

	shell.RunCommand(t, shell.Command{
		Command:    "tar",
		Args:       []string{"-xzf", chartTarPackagePath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	defer shell.RunCommand(t, shell.Command{
		Command:    "rm",
		Args:       []string{"-f", chartTarPackagePath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	defer shell.RunCommand(t, shell.Command{
		Command:    "rm",
		Args:       []string{"-rf", chartPackageRootPath},
		WorkingDir: "../..",
		Env:        map[string]string{},
	})

	output := helm.RenderTemplate(t, &helm.Options{
		ValuesFiles: []string{
			relativeChartPackageRootPath + "/values.yaml",
		},
	}, relativeChartPackageRootPath, "nginx", []string{"templates/deployment.yaml"})

	var deployment appsv1.Deployment
	helm.UnmarshalK8SYaml(t, output, &deployment)

	require.Equal(t, deployment.Spec.Template.Spec.Containers[0].Image, "fake-nginx:latest-fake")
}

kind create cluster --name bazel-tillerless
kubectl create namespace system-chartmuseum
helm3 install chartmuseum --namespace system-chartmuseum -f tests/resources/chartmuseum/values.yaml stable/chartmuseum
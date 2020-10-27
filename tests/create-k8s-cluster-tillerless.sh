kind create cluster --name bazel-tillerless
kubectl create namespace system-chartmuseum
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install chartmuseum --namespace system-chartmuseum -f tests/resources/chartmuseum/values.yaml stable/chartmuseum
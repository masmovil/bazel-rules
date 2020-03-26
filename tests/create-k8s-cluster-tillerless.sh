kind create cluster --name bazel-tillerless
kubectl create namespace system-chartmuseum
helm3 repo add stable https://kubernetes-charts.storage.googleapis.com/
helm3 repo update
helm3 install chartmuseum --namespace system-chartmuseum -f tests/resources/chartmuseum/values.yaml stable/chartmuseum
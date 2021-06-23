kind create cluster --config=./tests/cluster.yaml
docker ps
nmap -p- 127.0.0.1
kubectl cluster-info --context kind-bazel-rules
kubectl create namespace system-chartmuseum
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install chartmuseum --namespace system-chartmuseum -f tests/resources/chartmuseum/values.yaml stable/chartmuseum
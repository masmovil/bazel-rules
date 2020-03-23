kind create cluster --name bazel-tiller
kubectl create namespace tiller-system
"helm init --tiller-namespace tiller-system --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -"
kubectl apply -f ./tests/resources/kind/roles/roles-tiller.yaml --namespace=tiller-system
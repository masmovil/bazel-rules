# Install necessary tools
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-$(uname)-amd64"
sudo mv ./kind /usr/local/bin
sudo chmod +x /usr/local/bin/kind
wget https://github.com/bazelbuild/bazel/releases/download/4.1.0/bazel_4.1.0-linux-x86_64.deb
sudo dpkg -i bazel_4.1.0-linux-x86_64.deb
wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz
tar -zxvf helm-v3.6.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
wget https://github.com/ahmetb/kubectx/archive/v0.9.3.tar.gz -O ./kubectx.tar.gz
tar -zxvf kubectx.tar.gz
sudo mv kubectx-0.9.3/kubectx /usr/local/bin/kubectx
gpg --import tests/resources/pgp/sops_test_key.asc
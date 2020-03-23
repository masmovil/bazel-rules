curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.6.1/kind-$(uname)-amd64"
sudo mv ./kund /usr/local/bin
sudo chmod +x /usr/local/bin/kind
wget https://github.com/bazelbuild/bazel/releases/download/0.29.1/bazel_0.29.1-linux-x86_64.deb
# sha256sum -c tools/bazel_0.3.1-linux-x86_64.deb.sha256
sudo dpkg -i bazel_0.29.1-linux-x86_64.deb
wget https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz
tar -zxvf helm-v2.14.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm2
wget https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz
tar -zxvf helm-v3.1.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
wget https://github.com/ahmetb/kubectx/archive/v0.8.0.tar.gz -O ./kubectx.tar.gz
tar -zxvf kubectx.tar.gz
sudo mv kubectx-0.8.0/kubectx /usr/local/bin/kubectx
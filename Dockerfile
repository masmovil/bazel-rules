FROM ubuntu

RUN apt-get update && apt-get -y install curl wget g++ zlib1g-dev unzip gpg

# Install golang
RUN wget https://golang.org/dl/go1.16.5.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.5.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin

# Install bazel
RUN wget https://github.com/bazelbuild/bazel/releases/download/4.1.0/bazel_4.1.0-linux-x86_64.deb
RUN dpkg -i bazel_4.1.0-linux-x86_64.deb

# Install kubectl
RUN curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl

# Install kind
RUN curl -Lo /usr/local/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-$(uname)-amd64


# Install helm
RUN wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz
RUN tar -zxvf helm-v3.6.0-linux-amd64.tar.gz
RUN mv linux-amd64/helm /usr/local/bin/helm

# Install kubectx
RUN wget https://github.com/ahmetb/kubectx/archive/v0.9.3.tar.gz -O ./kubectx.tar.gz
RUN tar -zxvf kubectx.tar.gz
RUN mv kubectx-0.9.3/kubectx /usr/local/bin/kubectx

# Configure gpg
COPY ./tests/resources/pgp/sops_test_key.asc .
RUN gpg --import ./sops_test_key.asc
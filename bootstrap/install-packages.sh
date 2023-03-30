#!/usr/bin/env bash

# echo "Removendo pacotes antigos" && rm -rf /app/*

function install_kubectl() {
  local arch="amd64"

  if [ "$(arch)" == "aarch64" ]; then
    local arch="arm64"
  fi

  if [ ! -e /app/kubectl-${KUBECTL_VERSION} ]; then
    wget https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${arch}/kubectl
    mv kubectl /app/kubectl-${KUBECTL_VERSION}
    ln -sf /app/kubectl-${KUBECTL_VERSION} /app/kubectl
    chmod +x /app/kubectl-${KUBECTL_VERSION}
  fi
}

function install_aws() {
  local arch="x86_64"

  if [ "$(arch)" == "aarch64" ]; then
    local arch="aarch64"
  fi

  package="awscli-exe-linux-${arch}-${AWS_CLI_VERSION}.zip"

  if [ ! -e /app/aws-cli-${AWS_CLI_VERSION} ]; then
    wget https://awscli.amazonaws.com/${package}
    unzip -q ${package}
    ./aws/install --update \
    --install-dir /app/aws-cli-${AWS_CLI_VERSION} \
    --bin-dir /app/aws-cli-bin-${AWS_CLI_VERSION} >/dev/null

    ln -sf /app/aws-cli-${AWS_CLI_VERSION} /app/aws-cli
    ln -sf /app/aws-cli-bin-${AWS_CLI_VERSION} /app/aws-cli-bin

    rm ${package}
  fi
}

function install_istioctl() {
  local arch="amd64"

  if [ "$(arch)" == "aarch64" ]; then
    local arch="arm64"
  fi

  ISTIO_PACKAGE="istio-${ISTIOCTL_VERSION}-linux-${arch}.tar.gz"

  if [ ! -e /app/istioctl-${ISTIOCTL_VERSION} ]; then
    wget "https://storage.googleapis.com/istio-release/releases/${ISTIOCTL_VERSION}/${ISTIO_PACKAGE}"

    tar -xzf "${ISTIO_PACKAGE}" >/dev/null
    rm ${ISTIO_PACKAGE}
    cp -a istio-${ISTIOCTL_VERSION}/bin/istioctl /app/istioctl-${ISTIOCTL_VERSION}
    ln -sf /app/istioctl-${ISTIOCTL_VERSION} /app/istioctl

    PATH="$PATH:/app/istioctl"
  fi
}

function install_helm() {
  export VERIFY_CHECKSUM=false

  if [ ! -e /app/helm ]; then
    wget https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-${HELM_VERSION}
    bash get-helm-${HELM_VERSION} >/dev/null
    mv /usr/local/bin/helm /app/helm
  fi
}

function install_kustomize() {
  if [ ! -e /app/kustomize ]; then
    wget "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
    bash install_kustomize.sh >/dev/null
    mv /root/kustomize /app/kustomize
  fi
}

function install_argo() {
  local package="argocd-linux-amd64"

  if [ "$(arch)" == "aarch64" ]; then
    local package="argocd-linux-arm64"
  fi

  if [ ! -e /app/argocd ]; then
    wget "https://github.com/argoproj/argo-cd/releases/download/${ARGO_VERSION}/${package}"
    install -m 555 ${package} /app/argocd
    rm ${package}
  fi
}

function show_versions() {
  cat << EOT

As seguintes versões foram instaladas:
Istioctl: ${ISTIOCTL_VERSION}
Kubectl:   ${KUBECTL_VERSION}
AWS CLI:   ${AWS_CLI_VERSION}
Helm:      ${HELM_VERSION}
ARGO CLI:  ${ARGO_VERSION}

EOT
}

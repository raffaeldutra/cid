#!/usr/bin/env bash

# echo "Removendo pacotes antigos" && rm -rf ${ENV_DIRECTORY_INSTALLATION}/*

function install_kubectl() {
  local arch="amd64"

  if [ "$(arch)" == "aarch64" ]; then
    local arch="arm64"
  fi

  if [ ! -e ${ENV_DIRECTORY_INSTALLATION}/kubectl-${KUBECTL_VERSION} ]; then
    wget https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${arch}/kubectl
    mv kubectl ${ENV_DIRECTORY_INSTALLATION}/kubectl-${KUBECTL_VERSION}
    ln -sf ${ENV_DIRECTORY_INSTALLATION}/kubectl-${KUBECTL_VERSION} ${ENV_DIRECTORY_INSTALLATION}/kubectl
    chmod +x ${ENV_DIRECTORY_INSTALLATION}/kubectl-${KUBECTL_VERSION}
  fi
}

function install_aws() {
  local arch="x86_64"

  if [ "$(arch)" == "aarch64" ]; then
    local arch="aarch64"
  fi

  package="awscli-exe-linux-${arch}-${AWS_CLI_VERSION}.zip"

  if [ ! -e ${ENV_DIRECTORY_INSTALLATION}/aws-cli-${AWS_CLI_VERSION} ]; then
    wget https://awscli.amazonaws.com/${package}
    unzip -q ${package}
    ./aws/install --update \
    --install-dir ${ENV_DIRECTORY_INSTALLATION}/aws-cli-${AWS_CLI_VERSION} \
    --bin-dir ${ENV_DIRECTORY_INSTALLATION}/aws-cli-bin-${AWS_CLI_VERSION} >/dev/null

    ln -sf ${ENV_DIRECTORY_INSTALLATION}/aws-cli-${AWS_CLI_VERSION} ${ENV_DIRECTORY_INSTALLATION}/aws-cli
    ln -sf ${ENV_DIRECTORY_INSTALLATION}/aws-cli-bin-${AWS_CLI_VERSION} ${ENV_DIRECTORY_INSTALLATION}/aws-cli-bin

    rm ${package}
  fi
}

function install_istioctl() {
  local arch="amd64"

  if [ "$(arch)" == "aarch64" ]; then
    local arch="arm64"
  fi

  ISTIO_PACKAGE="istio-${ISTIOCTL_VERSION}-linux-${arch}.tar.gz"

  if [ ! -e ${ENV_DIRECTORY_INSTALLATION}/istioctl-${ISTIOCTL_VERSION} ]; then
    wget "https://storage.googleapis.com/istio-release/releases/${ISTIOCTL_VERSION}/${ISTIO_PACKAGE}"

    tar -xzf "${ISTIO_PACKAGE}" >/dev/null
    rm ${ISTIO_PACKAGE}
    cp -a istio-${ISTIOCTL_VERSION}/bin/istioctl ${ENV_DIRECTORY_INSTALLATION}/istioctl-${ISTIOCTL_VERSION}
    ln -sf ${ENV_DIRECTORY_INSTALLATION}/istioctl-${ISTIOCTL_VERSION} ${ENV_DIRECTORY_INSTALLATION}/istioctl

    PATH="$PATH:${ENV_DIRECTORY_INSTALLATION}/istioctl"
  fi
}

function install_helm() {
  export VERIFY_CHECKSUM=false

  if [ ! -e ${ENV_DIRECTORY_INSTALLATION}/helm ]; then
    wget https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-${HELM_VERSION}
    bash get-helm-${HELM_VERSION} >/dev/null
    mv /usr/local/bin/helm ${ENV_DIRECTORY_INSTALLATION}/helm
  fi
}

function install_kustomize() {
  if [ ! -e ${ENV_DIRECTORY_INSTALLATION}/kustomize ]; then
    wget "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
    bash install_kustomize.sh >/dev/null
    mv /root/kustomize ${ENV_DIRECTORY_INSTALLATION}/kustomize
  fi
}

function install_argo() {
  local package="argocd-linux-amd64"

  if [ "$(arch)" == "aarch64" ]; then
    local package="argocd-linux-arm64"
  fi

  if [ ! -e ${ENV_DIRECTORY_INSTALLATION}/argocd ]; then
    wget "https://github.com/argoproj/argo-cd/releases/download/${ARGO_VERSION}/${package}"
    install -m 555 ${package} ${ENV_DIRECTORY_INSTALLATION}/argocd
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

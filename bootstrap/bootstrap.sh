#!/usr/bin/env sh
shopt -s expand_aliases
source ~/.bash_aliases

source install-packages.sh

if [ -n "${AWS_CLI_VERSION}" ]; then
  install_aws
fi

if [ -n "${KUBECTL_VERSION}" ]; then
  install_kubectl
fi

if [ -n "${HELM_VERSION}" ]; then
  install_helm
fi

if [ -n "${ISTIOCTL_VERSION}" ]; then
  install_istioctl
fi

if [ -n "${KUSTOMIZE_VERSION}" ]; then
  install_kustomize
fi

if [ -n "${ARGO_VERSION}" ]; then
  install_argo
fi

show_versions

> ${ENV_DIRECTORY_INSTALLATION}/.finished

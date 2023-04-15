#!/usr/bin/env sh
shopt -s expand_aliases
source ~/.bash_aliases

source install-packages.sh

install_aws
install_kubectl
install_helm
install_istioctl
install_kustomize
install_argo
show_versions

> ${ENV_DIRECTORY_INSTALLATION}/.finished

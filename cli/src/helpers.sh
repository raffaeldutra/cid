if [ -e $HOME/.bash_aliases ]; then
  source $HOME/.bash_aliases
fi

declare InstallBasePackages=$(cat << EOT
  echo "Atualizando pacotes"
  apt-get update

  echo "Instalando pacotes"
  apt-get --yes install \
  curl \
  dnsutils \
  telnet \
  whois \
  traceroute \
  vim \
  jq \
  iputils-ping

  bash
EOT
)

# @function: HelperPodTemplate
# @description: Template para criar pods.
# @arg: HelperNamespace
# @arg: HelperImage
# @arg: HelperVersion
# @arg: HelperRandomChars
# @arg: HelperPodName
# @return: void
# @exitcode 0 Sucesso
function HelperPodTemplate() {
  local HelperNamespace="${1}"
  local HelperImage="${2}"
  local HelperVersion="${3}"
  local HelperRandomChars=${RANDOM}
  local HelperPodName="helper-${HelperImage}-${HelperRandomChars}"

  echo "Criando pod ${PodName}"

  kubectl run \
  --tty -i \
  --quiet \
  --rm \
  --restart=Never \
  --annotations="sidecar.istio.io/inject=false" \
  --namespace ${HelperNamespace} \
  --image ${HelperImage}:${HelperVersion} \
  --env DEBIAN_FRONTEND=noninteractive \
  --env DEBCONF_NOWARNINGS=yes \
  ${HelperPodName} -- /bin/bash -c "${InstallBasePackages}"
}

# @function: HelperKubernetesVanillaPodUbuntu
# @description: Template para pod em ubuntu vazio
# @arg: HelperPodName
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1
function HelperKubernetesVanillaPodUbuntu() {
  local HelperPodName=${1}

  kubectl run \
  --restart=Never \
  --annotations="sidecar.istio.io/inject=false" \
  --image ubuntu:22.04 \
  --env DEBIAN_FRONTEND=noninteractive \
  --env DEBCONF_NOWARNINGS=yes \
  ${HelperPodName} -- /bin/bash -c "while true; do echo 'Container em execução'; sleep 5; done"
}

# @function: HelperKubernetesPodUbuntu
# @description: Cria um Pod Ubuntu
# @arg: HelperNamespace
# @arg: HelperImage
# @arg: HelperVersion
# @return:
# @exitcode 0 Sucesso
# @exitcode 1
function HelperKubernetesPodUbuntu() {
  if [ "$(type -t HelperPodTemplate)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função HelperPodTemplate não encontrada"

    return 1
  fi

  local HelperNamespace="${1:-default}"
  local HelperImage="${2:-ubuntu}"
  local HelperVersion="${3:-22.04}"

  HelperPodTemplate ${HelperNamespace} ${HelperImage} ${HelperVersion}
}

# @function: HelperKubernetesPodNginx
# @description: Cria um pod Nginx
# @arg: HelperNamespace
# @arg: HelperImage
# @arg: HelperVersion
# @return: void
# @exitcode 0 Sucesso
function HelperKubernetesPodNginx() {
  local HelperNamespace="${1:-default}"
  local HelperImage="${2:-nginx}"
  local HelperVersion="${3:-1.23.1}"

  HelperPodTemplate ${HelperNamespace} ${HelperImage} ${HelperVersion}
}

# @function: HelperKubernetesPodDelete
# @description: Deleta todos os pods que foram criados via Helper
# @noargs
# @return: void
# @exitcode 0 Sucesso
function HelperKubernetesPodDelete() {
  kubectl get pod | \
  grep "helper" | \
  kubectl '{print $1}' | \
  while read HelperPod; do
    kubectl delete pod ${HelperPod}
  done
}

# @description: Converte páginas de documentação para PDF usando pandoc
# @function: HelperPandocCreatePDFFromMarkdown
# @description: Cria PDF a partir de arquivos Markdwon
# @noargs
# @return: void
# @exitcode 0 Sucesso
function HelperPandocCreatePDFFromMarkdown() {
  docker run \
  --rm \
  -w //data \
  --volume "/$(pwd):/data" \
  --user $(id -u):$(id -g) pandoc/latex:2.9 sh -c \
  'for f in *.md; do
    pandoc "$f" -s -o "${f%.md}.pdf"
  done'
}

# @function: HelperGetPasswordArgoCD
# @description: Retorna a senha do ArgoCD
# @noargs
# @return: void
# @exitcode 0 Sucesso
function HelperGetPasswordArgoCD() {
  if [ -z ${ENV_HELPER_KUBERNETES_NAMESPACE_ARGOCD} ]; then
    echo "${FUNCNAME[0]}: Não foi específicado o namespace do argocd, saindo"

    return 1
  fi

  kubectl -n ${ENV_HELPER_KUBERNETES_NAMESPACE_ARGOCD} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | \
  base64 -d
  echo
}

# @function: HelperGetPasswordGrafana
# @description: Retorna a senha do Grafana
# @noargs
# @return: void
# @exitcode 0 Sucesso
function HelperGetPasswordGrafana() {
  if [ -z ${ENV_HELPER_KUBERNETES_NAMESPACE_GRAFANA} ]; then
    echo "${FUNCNAME[0]}: Não foi específicado o namespace do grafana, saindo"

    return 1
  fi

  kubectl get secret -n ${ENV_HELPER_KUBERNETES_NAMESPACE_GRAFANA} grafana -o jsonpath="{.data.admin-password}" | \
  base64 -d
  echo
}

# @function: HelperGetPasswordDashboard
# @description: Retorna a senha do Dashboard
# @noargs
# @return: void
# @exitcode 0 Sucesso
function HelperGetPasswordDashboard() {
  if [ -z ${ENV_HELPER_KUBERNETES_NAMESPACE_K8S_DASHBOARD} ]; then
    echo "${FUNCNAME[0]}: Não foi específicado o namespace do Dashboard do Kubernetes, saindo"

    return 1
  fi

  kubectl -n ${ENV_HELPER_KUBERNETES_NAMESPACE_K8S_DASHBOARD} describe secret kubernetes-dashboard-token-fnbx9
}

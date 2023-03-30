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
  declare HelperNamespace="${1}"
  declare HelperImage="${2}"
  declare HelperVersion="${3}"
  declare HelperRandomChars=${RANDOM}
  declare HelperPodName="helper-${HelperImage}-${HelperRandomChars}"

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
  declare HelperPodName=${1}

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

  declare HelperNamespace="${1:-default}"
  declare HelperImage="${2:-ubuntu}"
  declare HelperVersion="${3:-22.04}"

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
  declare HelperNamespace="${1:-default}"
  declare HelperImage="${2:-nginx}"
  declare HelperVersion="${3:-1.23.1}"

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
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | \
  base64 -d
  echo
}

# @function: HelperGetPasswordGrafana
# @description: Retorna a senha do Grafana
# @noargs
# @return: void
# @exitcode 0 Sucesso
function HelperGetPasswordGrafana() {
  kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | \
  base64 -d
  echo
}

# @function: HelperGetPasswordDashboard
# @description: Retorna a senha do Dashboard
# @noargs
# @return: void
# @exitcode 0 Sucesso
function HelperGetPasswordDashboard() {
  kubectl -n kube-dashboard describe secret kubernetes-dashboard-token-fnbx9
}

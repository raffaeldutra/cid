# @function: KubernetesInitialConfigurationExists
# @description: Retorna 1 caso não for encontrado a configuração para Kubernetes
# @noargs
# @return: String<Number>
# @exitcode 1 Não for encontrada configuração para Kubernetes
function KubernetesInitialConfigurationExists() {
  if [ $(find $HOME/.kube -maxdepth 1 -type f | wc -l) -eq 0 ]; then
    echo 1
  fi

  echo 0
}

# @function: KubernetesGetCurrentCluster
# @description: Mostra o nome do atual cluster sendo utilizado
# @noargs
# @return: String
# @exitcode 0 Sucesso
function KubernetesGetCurrentCluster() {
  if [ $(KubernetesInitialConfigurationExists) -eq 1 ]; then
    echo "${FUNCNAME[0]}: Problema ao buscar o nome do cluster, saindo"

    return 1
  fi

  kubectl config view --minify -o jsonpath='{.clusters[].name}' | \
  cut -d "/" -f2 2>/dev/null
}

# @function: KubernetesGetCurrentNamespace
# @description: O nome atual sendo setado para o namespace
# @arg: KubernetesGetCurrentNamespace
# @return: String
# @exitcode 0 Sucesso
function KubernetesGetCurrentNamespace() {
  local KubernetesGetCurrentNamespace="$(
    kubectl config view --minify -o jsonpath='{..namespace}'
  )"

  if [ -z "${KubernetesGetCurrentNamespace}" ]; then
    echo "default"

    return 0
  fi

  echo ${KubernetesGetCurrentNamespace}
}

# @function: KubernetesSetCurrentNamespace
# @description: Mostra o contexto atual do namespace
# @arg: KubernetesNamespace
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro KubernetesNamespace não foi definido
function KubernetesSetCurrentNamespace() {
  local KubernetesNamespace=${1:-default}

  if [ -z ${KubernetesNamespace} ]; then
    echo "${FUNCNAME[0]}: Namespace não informado, saindo"

    return 1
  fi

  kubectl config set-context \
  --current \
  --namespace=${KubernetesNamespace}
}

# @function: KubernetesSetCurrentCluster
# @description: Seta o nome do cluster
# @arg: KubernetesClusterName
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Caso não encontre o arquivo do cluster
# @exitcode 1 Parâmetro KubernetesClusterName não foi definido
function KubernetesSetCurrentCluster() {
  local KubernetesClusterName=${1}

  if [ ! -f "${HOME}/.kube/${KubernetesClusterName}" -o -z ${KubernetesClusterName} ]; then
    echo "${FUNCNAME[0]}: Arquivo não encontrado ou variável não setada."
    echo "${FUNCNAME[0]}: Use ${_CYAN}${CLI_ALIAS} -ksc <cluster-name>${_RESET} para gerar arquivo de configuração."

    return 1
  fi

  kubectl config \
  --kubeconfig=${HOME}/.kube/${KubernetesClusterName} \
  set-cluster ${KubernetesClusterName}

  ln -sf ${HOME}/.kube/${KubernetesClusterName} ${HOME}/.kube/config
}

# @function: KubernetesListTopPodsBy
# @description: Lista todos os pods por cpu ou memória (default: memória) com várias opções
# @arg: KubernetesMetric
# @arg: KubernetesNamespace
# @arg: KubernetesTop
# @return: String
# @exitcode 0 Sucesso
function KubernetesListTopPodsBy() {
  cat <<EOT
Opções para metrica: ${_CYAN}cpu, memory${_RESET}, default: memory
Exemplos:
  ${CLI_ALIAS} -ktp                              Lista todos os pods de todos os namespaces por memoria
  ${CLI_ALIAS} -ktp -m cpu                       Lista todos os pods de todos os namespaces por cpu
  ${CLI_ALIAS} -ktp -m cpu -n monitoring         Lista maiores pods por cpu no namespace monitoring
  ${CLI_ALIAS} -ktp -n monitoring                Lista maiores pods por memoria no namespace monitoring
  ${CLI_ALIAS} -ktp -n monitoring -t 10          Lista os 10 maiores pods por memoria no namespace monitoring
  ${CLI_ALIAS} -ktp -m cpu -n monitoring -t 10   Lista os 10 maiores pods por cpu no namespace monitoring
  ${CLI_ALIAS} -ktp -t 5                         Lista os 5 maiores pods por mmória em todos os namespaces

EOT

  while getopts ":m:n:t:" opt; do
    case $opt in
      m) KubernetesMetric=("$OPTARG") ;;
      n) KubernetesNamespace=("$OPTARG") ;;
      t) KubernetesTop=("$OPTARG") ;;
    esac
  done

  if [ -z ${KubernetesMetric} ]; then
    local KubernetesMetric="memory"
  fi

  if [ -z ${KubernetesNamespace} ]; then
    local KubernetesNamespace="--all-namespaces"
  else
    local KubernetesNamespace="--namespace ${KubernetesNamespace}"
  fi

  echo "Listando pods em ${_CYAN}${KubernetesNamespace}${_RESET} filtrando por ${_CYAN}${KubernetesMetric}${_RESET}"
  if [ -z ${Top} ]; then
    local Top=10

    kubectl top pods ${KubernetesNamespace} \
    --sort-by=${KubernetesMetric} | \
    head -n ${KubernetesTop}
  else
    local Top=${KubernetesTop}

    kubectl top pods ${KubernetesNamespace} \
    --no-headers \
    --sort-by=${KubernetesMetric} | \
    head -n ${KubernetesTop}
  fi
}

# @function: KubernetesListAllServices
# @description: Lista todos os serviços
# @noargs
# @return: String
# @exitcode 0 Sucesso
function KubernetesListAllServices() {
  kubectl \
  --no-headers \
  --all-namespaces \
  get svc
}

# @function: KubernetesListServicesIgnoringFromList
# @description: Lista todos os serviços excluindo aqueles que o usuário não deseja no arquivo .env.config
# @noargs
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Função KubernetesListAllServices não foi encontrada
function KubernetesListServicesIgnoringFromList() {
  if [ "$(type -t KubernetesListAllServices)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função KubernetesListAllServices não encontrada"

    return 1
  fi

  if [ -z ${ENV_KUBERNETES_REMOVE_NAMESPACES} ]; then
    echo "${FUNCNAME[0]}: ENV_KUBERNETES_REMOVE_NAMESPACES não foi informado no arquivo .env.config"

    return 1
  fi

  KubernetesListAllServices | \
  grep -Evf <(printf '%s\n' "${ENV_KUBERNETES_REMOVE_NAMESPACES[@]}")
}

# @function: KubernetesAmountServicesIgnoringNamespaces
# @description: Retorna a quantidade de serviços que estão rodando no cluster ignorando namespaces espficiados.
# @noargs
# @return: Number
# @exitcode 0 Sucesso
# @exitcode 1 Função KubernetesListAllServices não foi encontrada
function KubernetesAmountServicesIgnoringNamespaces() {
  if [ "$(type -t KubernetesListAllServices)" != "function" ]; then
    echo "Função KubernetesListAllServices não encontrada"

    return 1
  fi

  KubernetesListAllServices | \
  grep -Evf <(printf '%s\n' "${ENV_KUBERNETES_REMOVE_NAMESPACES[@]}") | \
  wc -l
}

# @function: KubernetesAmountServices
# @description: Retorna a quantidade de serviços que estão rodando no cluster
# @noargs
# @return: Number
# @exitcode 0 Sucesso
# @exitcode 1 Função KubernetesListAllServices não foi encontrada
function KubernetesAmountServices() {
  if [ "$(type -t KubernetesListAllServices)" != "function" ]; then
    echo "Função KubernetesListAllServices não encontrada"

    return 1
  fi

  KubernetesListAllServices | wc -l
}

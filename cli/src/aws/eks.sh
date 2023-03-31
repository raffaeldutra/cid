# @function: AWSEKSGetClusters
# @description: Lista todos os clusters da conta utilizada no ambiente
# @noargs
# @return: List<String>
# @exitcode 0 Sucesso
function AWSEKSGetClusters() {
  aws eks list-clusters | \
  jq -r ".clusters[]"
}

# @function: AWSEKSGenerateAuths
# @description: Criar as credenciais para o cluster. Passe como argumento o cluster
# @arg: AWSEKSClusterName
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro AWSEKSClusterName foi definido
# @exitcode 1 Função AWSEKSGetClusters não foi encontrada
# @exitcode 1 Função KubernetesSetCurrentCluster não foi encontrada
# @exitcode 1 Não foi fornecido a configuração de kubernetes no arquivo .env.config
function AWSEKSGenerateAuths() {
  if [[ ! ${ENV_CONFIG_TOOLS[*]} =~ "kubernetes" ]]; then
    echo "${FUNCNAME[0]}: Kubernetes não foi fornecido no arquivo .env.config, saindo"

    exit 1
  fi

  if [ "$(type -t AWSEKSGetClusters)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetClusters não encontrada"

    return 1
  fi

  if [ "$(type -t KubernetesSetCurrentCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função KubernetesSetCurrentCluster não encontrada"

    return 1
  fi

  local AWSEKSClusterName=${1}

  if [ -z ${AWSEKSClusterName} ]; then
    echo "${FUNCNAME[0]}: Nome do cluster não informado, saindo"

    return 1
  fi

  echo "Aguarde, procurando o nome do cluster"
  AWSEKSGetClusters | while read AWSEKSCluster; do
    if [ "${AWSEKSCluster}" == "${AWSEKSClusterName}" ]; then
      echo; echo "${FUNCNAME[0]}: Cluster ${_CYAN}${AWSEKSClusterName}${_RESET} encontrado."

      aws eks update-kubeconfig \
      --name ${AWSEKSClusterName} \
      --kubeconfig ${HOME}/.kube/${AWSEKSClusterName}

      ln -sf ${HOME}/.kube/${AWSEKSClusterName} ${HOME}/.kube/config

      KubernetesSetCurrentCluster ${AWSEKSClusterName}

      echo; echo "Recarregando o PS1 para setar o cluster nas variáveis, aguarde.."; sleep 5
      source ${HOME}/.bashrc
      clear

      break
    else
      echo "${FUNCNAME[0]}: Cluster ${AWSEKSClusterName} não encontrado"
    fi
  done
}

# @function: AWSEKSGetAmountClusters
# @description: Mostra em valor inteiro a quantidade de clusters da conta
# @noargs
# @return: Number
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSEKSGetClusters não foi encontrada
function AWSEKSGetAmountClusters() {
  if [ "$(type -t AWSEKSGetClusters)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetClusters não encontrada"

    return 1
  fi

  AWSEKSGetClusters | wc -l
}

# @function: AWSEKSGetNodeGroupsByCluster
# @description: Mostra todos os node groups de um determinado cluster
# @noargs
# @return:
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro AWSEKSClusterName não foi definido
function AWSEKSGetNodeGroupsByCluster() {
  if [[ ! ${ENV_CONFIG_TOOLS[*]} =~ "kubernetes" ]]; then
    echo "${FUNCNAME[0]}: Kubernetes não foi fornecido no arquivo .env.config, saindo"

    exit 1
  fi

  if [ "$(type -t KubernetesGetCurrentCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função KubernetesGetCurrentCluster não encontrada"

    return 1
  fi

  local AWSEKSClusterName="${1}"

  if [ -z ${AWSEKSClusterName} ]; then
    local AWSEKSClusterName=$(KubernetesGetCurrentCluster)
  fi

  aws eks list-nodegroups \
  --cluster-name ${AWSEKSClusterName} | \
  jq -r '.nodegroups[]'
}

# @function: KubernetesListNodesPerLabel
# @description: Lista Nodes por label
# @arg: KubernetesClusterName
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSEKSGetNodeGroupsByCluster não foi encontrada
# @exitcode 1 Parâmetro KubernetesClusterName não foi definida
function AWSEKSListNodesPerLabel() {
  if [ "$(type -t AWSEKSGetNodeGroupsByCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetNodeGroupsByCluster não encontrada"

    return 1
  fi

  local KubernetesClusterName=${1}

  if [ -z ${KubernetesClusterName} ]; then
    local KubernetesClusterName=$(KubernetesGetCurrentCluster)
  fi

  for KubernetesGroup in $(AWSEKSGetNodeGroupsByCluster); do
    echo; echo -e "Listando máquinas para node group ${_CYAN}${KubernetesGroup}${_RESET}"

    kubectl get node --selector sre/node-group="$(
      echo ${KubernetesGroup} | \
      rev | \
      cut -d - -f2- | \
      rev
    )" \
    --no-headers
  done
}

# @function: AWSEKSDescribeNodeGroupsByCluster
# @description: Mostra detalhes sobre um determiando nodegroup
# @arg: AWSEKSClusterName
# @arg: AWSEKSNodeGroup
# @return: List<String>
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro AWSEKSClusterName não foi definido
# @exitcode 1 Parâmetro AWSEKSNodeGroup não foi definido
function AWSEKSDescribeNodeGroupsByCluster() {
  local AWSEKSNodeGroup="${1}"

  if [ -z ${AWSEKSNodeGroup} ]; then
    echo "${FUNCNAME[0]}: Informe o nodegroup a ser pesquisado, saindo"

    return 1
  fi

  aws eks describe-nodegroup \
  --cluster-name $(KubernetesGetCurrentCluster) \
  --nodegroup-name ${AWSEKSNodeGroup}
}

# @function: AWSEKSGetNodeGroupsInfos
# @description: Retorna informações detalhadas dos node groups do cluster.
# @description: Caso o nome do cluster não foi definido usará o valor setado corrente
# @arg: KubernetesGetCurrentCluster <Optional>
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSEKSGetClusters não foi encontrada
# @exitcode 1 Função AWSEKSGetNodeGroupsByCluster não foi encontrada
# @exitcode 1 Função AWSEKSDescribeNodeGroupsByCluster não foi encontrada
function AWSEKSGetNodeGroupsInfos() {
  if [ "$(type -t AWSEKSGetClusters)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetClusters não encontrada"

    return 1
  fi

  if [ "$(type -t AWSEKSGetNodeGroupsByCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetNodeGroupsByCluster não encontrada"

    return 1
  fi

  if [ "$(type -t AWSEKSDescribeNodeGroupsByCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSDescribeNodeGroupsByCluster não encontrada"

    return 1
  fi

  local KubernetesGetCurrentCluster="${1}"

  if [ -z ${KubernetesGetCurrentCluster} ]; then
    echo "${FUNCNAME[0]}: Não foi informado um cluster a ser pesquisado."
    echo "${FUNCNAME[0]}: Usando o cluster corrente ${_CYAN}$(KubernetesGetCurrentCluster)${_RESET}"

    local KubernetesGetCurrentCluster="$(KubernetesGetCurrentCluster)"
  fi

  AWSEKSGetClusters | \
  while read AWSEKSClusterName; do
    echo "${AWSEKSClusterName}: "
    AWSEKSGetNodeGroupsByCluster $(KubernetesGetCurrentCluster) | \
    while read AWSEKSNodeGroupName; do
      AWSEKSDescribeNodeGroupsByCluster ${AWSEKSClusterName} ${AWSEKSNodeGroupName} | \
      jq ${NodeGroupInformation}
    done
  done
}

# @function: AWSEKSGetAmountNodes
# @description: Mostra a quantidade de nodes que tem em um determinado cluster
# @noargs
# @return: Number
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSEKSGetClusters não foi encontrada
# @exitcode 1 Função AWSEKSGetNodeGroupsByCluster não foi encontrada
# @exitcode 1 Função AWSEKSDescribeNodeGroupsByCluster não foi encontrada
function AWSEKSGetAmountNodes() {
  if [ "$(type -t AWSEKSGetClusters)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetClusters não encontrada"

    return 1
  fi

  if [ "$(type -t AWSEKSGetNodeGroupsByCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetNodeGroupsByCluster não encontrada"

    return 1
  fi

  if [ "$(type -t AWSEKSDescribeNodeGroupsByCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSDescribeNodeGroupsByCluster não encontrada"

    return 1
  fi

  AWSEKSGetClusters | \
  while read AWSEKSClusterName; do
    echo -n "${AWSEKSClusterName}: "
    AWSEKSGetNodeGroupsByCluster ${AWSEKSClusterName} | \
    while read AWSEKSNodeGroup; do \
      AWSEKSDescribeNodeGroupsByCluster ${AWSEKSClusterName} ${AWSEKSNodeGroup} | \
      jq '.nodegroup.scalingConfig.desiredSize'
    done | \
    paste -s -d+ - | \
    bc
  done
}

# @function: AWSEKSGetClusterVersion
# @description: Mostra a versão do AWSEKS de um determinado cluster
# @noargs
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSEKSGetClusters não foi encontrada
function AWSEKSGetClusterVersion() {
  if [ "$(type -t AWSEKSGetClusters)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetClusters não encontrada"

    return 1
  fi

  AWSEKSGetClusters | \
  while read AWSEKSClusterName; do
    echo -n "${AWSEKSClusterName}: "
    aws eks describe-cluster \
    --name ${AWSEKSClusterName} | \
    jq -r '.cluster.version'
  done
}

# @function: AWSEKSGetAmountNodeGroups
# @description: Mostra a quantidade de node groups de um determinado cluster
# @noargs
# @return: Number
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSEKSGetClusters não foi encontrada
# @exitcode 1 Função AWSEKSGetNodeGroupsByCluster não foi encontrada
function AWSEKSGetAmountNodeGroups() {
  if [ "$(type -t AWSEKSGetClusters)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetClusters não encontrada"

    return 1
  fi

  if [ "$(type -t AWSEKSGetNodeGroupsByCluster)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetNodeGroupsByCluster não encontrada"

    return 1
  fi

  AWSEKSGetClusters | \
  while read AWSEKSClusterName; do
    echo -n "${AWSEKSClusterName}: "
    AWSEKSGetNodeGroupsByCluster ${AWSEKSClusterName} | \
    wc -l
  done
}

# @function: AWSEKSListNodeGroupsNamesByCluster
# @description: Retorna os nomes dos node groups por Cluster
# @noargs
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSEKSGetNodeGroupsInfos não foi encontrada
function AWSEKSListNodeGroupsNamesByCluster() {
  if [ "$(type -t AWSEKSGetNodeGroupsInfos)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetNodeGroupsInfos não encontrada"

    return 1
  fi

  AWSEKSGetNodeGroupsInfos '.nodegroup.nodegroupName'
}

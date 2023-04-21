clear

if [ -z ${CLI_FULL_PATH} ]; then
  echo "Parâmetro CLI_FULL_PATH não foi definido no aquivo .env.config"

  return 1
fi

source "${CLI_FULL_PATH}/src/environment.sh"

function ShowPercentBar() {
  OsIsChristmasWeek
  declare Percent=${1}

  if [ ${Percent} -eq 100 ]; then
    Message="\e[44;33;1m%s\e[0m %s%% %b\n"
    Emoji=${EndEmoji}
  else
    Message="\e[44;33;1m%s\e[0m %s%%  %b\r"
    Emoji=${StartEmoji}
  fi

  printf "Carregando ambiente:${Message}" "${Progress}" ${Percent} ${Emoji}
}

declare Percent=20

if [ -f /etc/profile.d/bash_completion.sh ]; then
  source /etc/profile.d/bash_completion.sh
fi

ShowPercentBar 25
sleep 1

function EnvironmentOnInitializationLoadGit() {
  if [ "$(type -t GitGetCurrentBranch)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função GitGetCurrentBranch não encontrada"

    return 1
  fi

  if [ -z ${ENV_CONFIG_GIT_MASTER_BRANCHES} ]; then
    echo "ENV_CONFIG_GIT_MASTER_BRANCHES não foi definido no arquivo .env.config"

    return 1
  fi

  local GitVersion=$(git --version | awk '{print $3}')

  if [ $(GitGetCurrentBranch) ]; then
    local GitOutput="| (git:$(GitGetCurrentBranch)|${GitVersion})"

    for GitMasterBranchName in ${ENV_CONFIG_GIT_MASTER_BRANCHES[@]}; do
      if [ "$(GitGetCurrentBranch)" == "${GitMasterBranchName}" ]; then
        local GitOutput="| (git:${_RED}$(GitGetCurrentBranch)${_RESET}|${GitVersion})"
      fi
    done
  fi

  echo ${GitOutput}
}

declare KubernetesPS1CacheInformations="/tmp/PS1CacheInformations"

function KubernetesGenerateCacheInformationsPS1() {
  # if [ 0 -gt 0 ]; then
  if [ "$(type -t AWSEKSGetAmountClusters)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSEKSGetAmountClusters não encontrada"

    return 1
  fi

  if [ $(AWSEKSGetAmountClusters) -gt 0 ]; then
    rm ${KubernetesPS1CacheInformations} 2>/dev/null

    echo "c:$(cat /root/.kube/config | grep "cluster: arn:aws:eks:${AWS_DEFAULT_REGION}" | cut -d "/" -f2)" >> ${KubernetesPS1CacheInformations}
    echo "a:$(AWSEKSGetAmountClusters)" >> ${KubernetesPS1CacheInformations}

    source <(kubectl completion bash)
    complete -o default -F __start_kubectl k
  fi
}

# @function: EnvironmentLoadPS1
# @description: Ambientes que tem algum cluster rodando, receberão este tipo de configuração
# @arg: EKSClusterName
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro ENV_CONFIG_BASH não foi definido no arquivo .env.config
# @exitcode 1 Função KubernetesGetCurrentNamespace não foi encontrada
function EnvironmentLoadPS1() {
  PS1="\n[ \$(OsGetTime) \${CLIENT_NAME} | \${COLOR}\h@\u\${_RESET} :\w ]"

  if [ -z "${ENV_CONFIG_BASH}" ]; then
    echo "Parâmetro ENV_CONFIG_BASH não foi definido no arquivo .env.config"

    return 1
  fi

  local Percent=50
  for EnvironmentOnInitializationLoad in ${ENV_CONFIG_BASH[@]}; do
    ShowPercentBar ${Percent}
    sleep 0.3
    Percent=$((Percent+1))

    if [ ${EnvironmentOnInitializationLoad} == "kubernetes" -a -e "${HOME}/.kube/config" ]; then
      KubernetesGenerateCacheInformationsPS1

      if [ -e "${KubernetesPS1CacheInformations}" ]; then
        local KubernetesPS1ClusterName="$(cat ${KubernetesPS1CacheInformations} | grep c:)"
        local KubernetesPS1ClusterAmount="$(cat ${KubernetesPS1CacheInformations} | grep a:)"

        PS1="${PS1} | (${KubernetesPS1ClusterName}|${KubernetesPS1ClusterAmount}|n:\$(KubernetesGetCurrentNamespace))"
      fi
    fi

    if [ ${EnvironmentOnInitializationLoad} == "terraform" ]; then
      PS1="${PS1} \$(TerraformGetCurrentWorkspace)"
    fi

    if [ ${EnvironmentOnInitializationLoad} == "git" ]; then
      PS1="${PS1} \$(EnvironmentOnInitializationLoadGit)"
    fi
  done

  PS1="${PS1} \n=> "
}

# Para mais ambientes, acrescente aqui.
if [[ "$(hostname)" =~ "dev" ]]; then
  COLOR=${_GREEN}

  EnvironmentLoadPS1
  ShowPercentBar 75
elif [[ "$(hostname)" =~ "qa" ]]; then
  COLOR=${_CYAN}

  EnvironmentLoadPS1
  ShowPercentBar 75
elif [[ "$(hostname)" =~ "sb" ]]; then
  COLOR=${_YELLOW}

  EnvironmentLoadPS1
  ShowPercentBar 75
else
  COLOR=${_RED}
  EnvironmentLoadPS1
  ShowPercentBar 75
fi

ShowPercentBar 100

if [ -z "$(ls -A -- "${ENV_DIRECTORY_INSTALLATION}")" -o ! -f ${ENV_DIRECTORY_INSTALLATION}/.finished ]; then
  echo "Parece que o diretório com ferramentas de linha de comando está vazio/incompleto."
  echo "Aguarde até o processo terminar, pode demorar um pouco."; sleep 3; echo

  if [ ! -e "/tmp/bootstrap.sh" ]; then
    echo "Arquivo para instalação inicial não foi encontrado, saindo..."
    sleep 5

    exit 1
  fi

  bash /tmp/bootstrap.sh

  if [ $? -ne 0 ]; then
    echo "Oops, parece que alguma coisa deu errada."

    exit 1
  else
    echo "Enjoy :-)"
    sleep 3

    clear
  fi
fi

echo "Para utilizar a linha de comando, utilize o comando ${_CYAN}${CLIENT_NAME}${_RESET} ou o alias ${_CYAN}${CLI_ALIAS}${_RESET}"
echo "Para procurar uma função para ser utilizada (são muitas), utilize por exemplo ${_CYAN}${CLI_ALIAS} -s kubernetes${_RESET}"

# Se kubernetes foi definido em .env.config vamos mostrar a mensagem para rodar os comandos iniciais do kubernetes
# para poder configurar o cluster caso não encontre nenhum cluster setado.
if [[ ${ENV_CONFIG_TOOLS[*]} =~ "kubernetes" ]]; then
  if [ $(find $HOME/.kube -maxdepth 1 -type f | wc -l) -eq 0 ]; then
    echo
    echo "Você selecionou Kubernetes como ferramenta a ser utilizada neste container, porém não encontrei a configuração."
    echo "Rode ${_CYAN}${CLI_ALIAS} -kgc${_RESET} para listar os clusters definidos neste ambiente"
    echo "Rode ${_CYAN}${CLI_ALIAS} -kga <cluster>${_RESET} para gerar o kubeconfig do cluster"
    echo
  fi
fi

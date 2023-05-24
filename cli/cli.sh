#!/usr/bin/env bash

# Include de todos os arquivos da ${CLI_ALIAS} que foram previamente selecionados
source ${HOME}/.env.config

declare _RED="$(tput setaf 1)"
declare _GREEN="$(tput setaf 2)"
declare _YELLOW=$(tput setaf 3)
declare _BLUE=$(tput setaf 4)
declare _MAGENTA=$(tput setaf 5)
declare _CYAN=$(tput setaf 6)
declare _WHYTE=$(tput setaf 7)
declare _RESET=$(tput sgr0)
declare _BOLD=$(tput bold)

function HelpShowFunctionNamesAWS() {
cat << EOT

Funções para Aws
  Segurança
  -adc     | AwsGetCredentials                              Mostra suas credenciais

  CloudFront
  -agcf    | AwsCloudfrontListAllById                       Lista as distribuições do Cloud Front

  API Gateway
  -aagwgra | AwsApiGatewayGetRestAPIs                       Lista todas REST APIs
  -aagwga  | AwsApiGatewayGetAll                            Lista os nomes de domínios vinculados no API Gateway
  -aagwgr  | AwsApiGatewayGetResources                      Lista os recursos do API Gateway
  -aagwri  | AwsApiGatewayGetResourcesIntegrationRequests   Lista os recursos integrados aos requests (lambas por exemplo)

  Secrets Manager
  -asmga   | AwsSecretsManagerListAll                       Lista todas as secrets cadastradas no Secrets Manager
  -asmgabn | AwsSecretsManagerListByName                    Lista todas as secrets cadastradas no Secrets Manager por nome
  -asmgbt  | AwsSecretsManagerListByTag                     Lista chave pela tag
  -asmdf   | AwsSecretsManagerDeleteForced                  Deleta chave na marretada. Passe como argumento a chave que deseja deletar
             Exemplo: ${CLI_ALIAS} -asmdf <chave>

  Funções para Lambdas
  -allf    | AwsLambdaListFunctions                         Lista todas functions
  -alif    | AwsLambdaInvokeFunction                        Executa uma function
             Exemplo: ${CLI_ALIAS} -allf
             Ao listar as functions: ${CLI_ALIAS} -alif <function_name>

  Funções para AWSEKS
  -kga     | AWSEKSGenerateAuths                            Criar as credenciais para o cluster. Passe como argumento o cluster
             Exemplo: ${CLI_ALIAS} -kga cluster-dev

  -kgc     | AWSEKSGetClusters                              Mostra todos os clusters criados na conta
  -kgac    | AWSEKSGetAmountClusters                        Mostra em valor inteiro a quantidade de clusters da conta
  -kgan    | AWSEKSGetAmountNodes                           Mostra a quantidade de nodes que tem em um determinado cluster
  -kgang   | AWSEKSGetAmountNodeGroups                      Mostra a quantidade de node groups de um determinado cluster
  -kgcv    | AWSEKSGetClusterVersion                        Mostra a versão do Kubernetes de um determinado cluster
  -kgni    | AWSEKSGetNodeGroupsInfos                       Retorna informações detalhadas dos node groups do cluster
  -kdngbc  | AWSEKSDescribeNodeGroupsByCluster              Mostra detalhes sobre um determiando nodegroup
  -kgnbc   | AWSEKSListNodeGroupsNamesByCluster             Lista os nomes dos node groups de um cluster
  -klnpl   | AWSEKSListNodesPerLabel                        Lista Nodes por label

EOT
}

function HelpShowFunctionNamesKubernetes() {
cat << EOT

Funções para Kubernetes
  -kgcn    | KubernetesGetCurrentNamespace                  Mostra o contexto atual do namespace
  -ksn     | KubernetesSetCurrentNamespace                  Seta o namespace que deseja utilizar
             Exemplo: ${CLI_ALIAS} -ksn <monitoring>
             Irá para o namespace monitoring

             Exemplo: ${CLI_ALIAS} -ksn
             Irá para o namespace default

  -ksc     | KubernetesSetCurrentCluster                    Seta o via KUBE_CONFIG_PATH (arquivo) o cluster que deseja utilizar
             Exemplo: ${CLI_ALIAS} -ksc <cluster-2>
             Irá para o cluster cluster-2

  Secrets
  -kgss    | KubernetesGetSpecificSecret                    Mostra uma determinada secret
  -kgs     | KubernetesGetAllSecrets                        Lista todas as secrets de um cluster

  Services
  -klas    | KubernetesListAllServices                      Lista todos os seriços
  -klase   | KubernetesListServicesIgnoringFromList         Lista todos os seriços ignorando os específicados pelo usuário no .env.config
  -kas     | KubernetesAmountServices                       Mostra a quantidade de serviços que estão no cluster
  -kasin   | KubernetesAmountServicesIgnoringNamespaces     Mostra quantidade de serviços que estão no cluster ignorando namespaces específicados pelo usuário no .env.config

  -ktp     | KubernetesListTopPodsBy                        Lista todos os pods por cpu ou memória (default: memória)
  Exemplos:
    Listar todos os pods de todos os namespaces por memoria
    ${CLI_ALIAS} -ktp

    Listar todos os pods de todos os namespaces por cpu
    ${CLI_ALIAS} -ktp -m cpu

    Listar maiores pods por cpu no namespace monitoring
    ${CLI_ALIAS} -ktp -m cpu -n monitoring

    Listar maiores pods por memoria no namespace monitoring
    ${CLI_ALIAS} -ktp -n monitoring

    Listar os 10 maiores pods por memoria no namespace monitoring
    ${CLI_ALIAS} -ktp -n monitoring -t 10

    Listar os 5 maiores pods por cpu no namespace monitoring
    ${CLI_ALIAS} -ktp -m cpu -n monitoring -t 5

    Listar os 5 maiores pods por memorua em todos os namespaces
    ${CLI_ALIAS} -ktp -t 5
EOT
}

function HelpShowFunctionNamesOS() {
cat << EOT

Funções para Os (Sistema Operacional)
  -osssh   | OsCreateSSHKeys                                Cria uma chave ssh em ${HOME}/.ssh/<chave>/id_rsa
  -osgfm   | OsGetFreeMemory                                Mostra a quantidade de memória livre disponível
  -osgt    | OsGetTime                                      Mostra a hora atual
  -osgtu   | OsGetTimeUTC                                   Mostra a hora atual em UTC
  -oscub   | OsCompareUTCWithBrazilianTime                  Mostra a hora em UTC com nosso fuso
  -ospff   | OsPermissionForFilesSanitization               Seta permissionamento para 644 nos arquivos (geralmente o padrão)
  -ospfd   | OsPermissionForDirectoriesSanitization         Seta permissionamento para 644 nos diretórios (geralmente o padrão)
EOT
}

function HelpShowFunctionNamesRabbitMQ() {
cat << EOT

Funções para RabbitMQ
  -rmqgu   | RabbitMQGetUsers                               Retorna user
  -rmqgm   | RabbitMQGetMessages                            Retorna messages
  -rmqge   | RabbitMQGetExtensions                          Retorna extensions
  -rmqgd   | RabbitMQGetDefinitions                         Retorna definitions
  -rmqlc   | RabbitMQListConnections                        Mostra a lista de conexões
  -rmqgac  | RabbitMQGetAmountConnections                   Mostra a quantidade de conexões abertas
  -rmqlcn  | RabbitMQListConnectionsName                    Mostra a lista de conexões por nome
EOT
}

function HelpShowFunctionNamesHelpers() {
cat << EOT

Funções para Helpers
  -hpu     | HelperKubernetesPodUbuntu                      Cria um pod com Ubuntu com algumas ferramentas já instaladas
  -hpb     | HelperKubernetesPodNginx                       Cria um pod de teste com Nginx
  -hpd     | HelperKubernetesPodDelete                      Remove todos os pods com prefixo helper
  -hgpa    | HelperGetPasswordArgoCD                        Busca a senha para dashboard do ArgoCD
  -hgpg    | HelperGetPasswordGrafana                       Busca a senha para dashboard do Grafana
  -hgpk    | HelperGetPasswordDashboard                     Busca a senha para dashboard do Kubernetes
  -hgtk    | HelperGetTokenKeycloak                         Retorna o token de um determinado client_id
  Exemplo:
  ${CLI_ALIAS} -hgtk backend_app_wallet xxxxxxxx
EOT
}

function HelpShowFunctionNamesTerraform() {
cat << EOT

Funções para Terraform
  -tic     | TerraformInitCommand                           Mostra os possíveis comandos para terraform init
  -tgcw    | TerraformGetCurrentWorkspace                   Mostra o workspace atual dentro de um rpositório
  -tsv     | TerraformSetVersion                            Seta uma nova versão do Terraform caso não existir o arquivo versions.tf
  Exemplo:
  ${CLI_ALIAS} -tsc 1.3.5

  -tsiv    | TerraformShowInstalledVersions                 Mostra versões que estão baixadas no ambiente
EOT
}


function HelpShowFunctionNamesDocker() {
cat << EOT

Funções para Docker
  -did     | DockerIsThisDocker                             Se o ambiente é Docker
  -dgt     | DockerGetTag                                   Mostra tags para uma determinada imagem solicitada
EOT
}

function HelpShowFunctionNamesTests() {
cat << EOT

Funções para Testes
  -taf     | TestAllFunctions                               Testa todas as funções se conseguem ser chamadas
  -tsr     | TestShowMeResults                              Mostra a quantidade de funções criadas vs quantas foram declaradas
  -tsf     | TestSearchFunctionsCreated                     Mostra em uma lista todas as funções criadas
  -tlf     | TestListFunctions                              Mesma coisa que a função TestSearchFunctionsCreated porém sem sufixo
  -tgat    | TestGetAmountTestedFunctions                   Mostra a quantidade de funções testadas
  -tsfn    | TestShowFunctionNames                          Mostra a lista de funções testadas
EOT
}

function help() {
  local HelpShowFunctionName="${1}"

  for ToolsToInclude in ${ENV_CONFIG_TOOLS[@]}; do
    if [ "${ToolsToInclude}" == "aws" ]; then
      HelpShowFunctionNamesAWS
    fi

    if [ "${ToolsToInclude}" == "docker" ]; then
      HelpShowFunctionNamesDocker
    fi

    if [ "${ToolsToInclude}" == "helpers" ]; then
      HelpShowFunctionNamesHelpers
    fi

    if [ "${ToolsToInclude}" == "kubernetes" ]; then
      HelpShowFunctionNamesKubernetes
    fi

    if [ "${ToolsToInclude}" == "rabbitmq" ]; then
      HelpShowFunctionNamesRabbitMQ
    fi

    if [ "${ToolsToInclude}" == "terraform" ]; then
      HelpShowFunctionNamesTerraform
    fi
  done

  HelpShowFunctionNamesOS
  HelpShowFunctionNamesTests
}

# @function: Search
# @description: Faz a pesquisa na documentação
# @return: Text
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro Search não foi definido
function Search() {
  local Search="${1}"

  if [ -z ${Search} ]; then
    echo "Passe a string que deve ser procurada"

    return 1
  fi

  echo "Listando funções para ${_CYAN}${Search}${_RESET}"

  help | grep -v "Funções" | grep -Ei "${Search^}"
}

# @function: Summary
# @description: Mostra a quantidade de linhas de cada arquivo .sh
# @return: Text
# @exitcode 0 Sucesso
function Summary() {
  find ${CLI_FULL_PATH} -name "*.sh" | xargs wc -l
}

function ResetPS1() {
  source ${HOME}/.bashrc
}

# Arquivos que sempre serão carregados no container
source "${CLI_FULL_PATH}/src/os.sh"
source "${CLI_FULL_PATH}/src/docker.sh"
source "${CLI_FULL_PATH}/src/git.sh"

# Inclusão do arquivo que realiza todos os testes das Functions
if [ -e "${CLI_FULL_PATH}/tests/bootstrap.sh" ]; then
  source ${CLI_FULL_PATH}/tests/bootstrap.sh
fi

case "$1" in
  -h  | "" ) help ;;
  -s  ) Search ${2} ;;
  -ss ) Summary ;;
  -rs ) ResetPS1 ;;
  * )
    # Faz include dos arquivos que foram selecionados no arquivo .env.config
    for ToolsToInclude in ${ENV_CONFIG_TOOLS[@]}; do
      if [ -f "${CLI_FULL_PATH}/src/${ToolsToInclude}.sh" ]; then
        source "${CLI_FULL_PATH}/src/${ToolsToInclude}.sh"
      fi

      # Arquivo kubernetes.sh
      if [ "${ToolsToInclude}" == "kubernetes" ]; then
        case "$1" in
          # Metrics
          -ktp     )
            KubernetesListTopPodsBy $@ ;;

          # Cluster
          -kgcn    )
            KubernetesGetCurrentNamespace ;;
          -ksc     )
            KubernetesSetCurrentCluster ${2} ;;
          -ksn     )
            KubernetesSetCurrentNamespace ${2} ${3} ;;

          # Secrets
          -kgss    )
            KubernetesGetSpecificSecret ;;
          -kgs     )
            KubernetesGetAllSecrets ;;

          # Services
          -klas     )
            KubernetesListAllServices ;;
          -klase    )
            KubernetesListServicesIgnoringFromList ;;
          -kas    )
            KubernetesAmountServices ;;
          -kasin    )
            KubernetesAmountServicesIgnoringNamespaces ;;
        esac
      fi

      # Arquivo aws.sh (dentro deste arquivo carregamos os demais arquivos utilizados pelo provider)
      if [ "${ToolsToInclude}" == "aws" ]; then
        case "$1" in

          -adc     )
            AWSGetCredentials ;;

          # Cloudfront
          -agcf    )
            AWSCloudfrontListAllById ;;

          # API Gateway
          -aagwga  )
            AWSApiGatewayGetAll ;;
          -aagwgra )
            AWSApiGatewayGetRestAPIs ;;
          -aagwgr  )
            AWSApiGatewayGetResources ;;
          -aagwri  )
            AWSApiGatewayGetResourcesIntegrationRequests ;;

          # Secrets Manager
          -asmga   )
            AWSSecretsManagerGetAll ;;
          -asmgabn )
            AWSSecretsManagerGetByName ;;
          -asmgbt  )
            AWSSecretsManagerGetByTag ${2} ;;
          -asmdf   )
            AWSSecretsManagerDeleteForced ${2} ;;

        # Lambdas
          -allf    )
            AWSLambdaListFunctions ;;
          -alif    )
            AWSLambdaInvokeFunction ${2} ;;

        # EKS
          -kgc     )
            AWSEKSGetClusters ;;
          -kga     )
            AWSEKSGenerateAuths ${2} ;;
          -kgac    )
            AWSEKSGetAmountClusters ;;
          -kgan    )
            AWSEKSGetAmountNodes ;;
          -kgcv    )
            AWSEKSGetClusterVersion ;;
          -kgnc    )
            AWSEKSGetNodeGroupsFilteredByCluster ;;
          -kgnbc   )
            AWSEKSGetNodeGroupsByCluster ;;
          -kgang   )
            AWSEKSGetAmountNodeGroups ;;
          -kdngbc  )
            AWSEKSDescribeNodeGroupsByCluster ${2};;
          -kgni    )
            AWSEKSGetNodeGroupsInfos ${2} ;;
          -klnpl   )
            AWSEKSListNodesPerLabel ;;
        esac
      fi

      # Arquivo helpers.sh
      if [ "${ToolsToInclude}" == "helpers" ]; then
        case "$1" in
          -hpu     )
            HelperKubernetesPodUbuntu ;;
          -hpb     )
            HelperKubernetesPodNginx ;;
          -hpd     )
            HelperKubernetesPodDelete ;;
          -hdgt    )
            HelperDockerGetTag ${2} ;;
          -hgpa    )
            HelperGetPasswordArgoCD ;;
          -hgpg    )
            HelperGetPasswordGrafana ;;
          -hgpk    )
            HelperGetPasswordDashboard ;;
          -hgtk    )
            HelperGetTokenKeycloak ${2} ${3} ;;
        esac
      fi

      # Arquivo rabbitmq.sh
      if [ "${ToolsToInclude}" == "rabbitmq" ]; then
        case "$1" in
          -rmqhelp )
            RabbitMQHelp ;;
          -rmqgu   )
            RabbitMQCheckEnvironmentVariables
            RabbitMQGetUsers ;;
          -rmqgm   )
            RabbitMQCheckEnvironmentVariables
            RabbitMQGetMessages ;;
          -rmqge   )
            RabbitMQCheckEnvironmentVariables
            RabbitMQGetExtensions ;;
          -rmqgd   )
            RabbitMQCheckEnvironmentVariables
            RabbitMQGetDefinitions ;;
          -rmqlc   )
            RabbitMQListConnections $@ ;;
          -rmqgac  )
            RabbitMQGetAmountConnections ;;
          -rmqlcn  )
            RabbitMQListConnectionsName ;;
        esac
      fi

      # Arquivo terraform.sh
      if [ "${ToolsToInclude}" == "terraform" ]; then
        case "$1" in
          -tic     )
            TerraformInitCommand ;;
          -tgcw    )
            TerraformGetCurrentWorkspace ;;
          -tsc     )
            TerraformDirectoryAndFileStructureCreate ${2} ${3} ;;
          -tsv     )
            TerraformSetVersion ${2} ;;
          -tsiv    )
            TerraformShowInstalledVersions ;;
        esac
      fi
    done

    # Demais funções que sempre serão inseridas nos containers
    case "$1" in
      # OS
      -osssh   )
        OsCreateSSHKeys ;;
      -osgfm   )
        OsGetFreeMemory ;;
      -osgt    )
        OsGetTime ;;
      -osgtu   )
        OsGetTimeUTC ;;
      -oscub   )
        OsCompareUTCWithBrazilianTime ;;
      -ospff   )
        OsPermissionForFilesSanitization ;;
      -ospfd   )
        OsPermissionForDirectoriesSanitization ;;

      # Testes
      -taf     )
        TestAllFunctions ;;
      -tsr     )
        TestShowMeResults ;;
      -tsf     )
        TestSearchFunctionsCreated ;;
      -tlf     )
        TestListFunctions ;;
      -tsfn    )
        TestShowFunctionNames ;;
      -tgat    )
        TestGetAmountTestedFunctions ;;
    esac
esac

# Mostra mensagem de sucesso ou falha
function TestSuccessOrFailMessage() {
  local StatusCode=${1}
  local FunctionName=${2}

  echo -n "Testing "
  if [ ${StatusCode} -eq 0 ]; then
    echo -e "${FunctionName}: ${_GREEN}OKAY${_RESET}"
  else
    echo -e "${FunctionName}: ${_RED}FAIL${_RESET}"
  fi
}

function TestSearchFunctionsCreated() {
  cat ${CLI_FULL_PATH}/src/*.sh | \
  grep -E "^function [A-Z]" | \
  sed 's|()||g;s|[{}]||g'
}

function TestListFunctions() {
  TestSearchFunctionsCreated | \
  awk '{print $2}'
}

function TestCompareFunctionsCreateWithCalled() {
  cat ${CLI_FULL_PATH}/${CLIENT_NAME}.sh | \
  sed -n '/case/,/esac/p' | \
  grep -v "#" | \
  grep -E "[A-Z]" | \
  sed 's| ||g;s|[${};;]||g;s|[0-9]||g' # Melhorar esse sed
}

function TestShowFunctionNames() {
  cat ${CLI_FULL_PATH}/tests/bootstrap.sh | \
  sed -n '/TestAllFunctions() {/,/}/p' | \
  sed '1d;$ d' | \
  sed '/#/d' | \
  sed '/^$/d' | \
  sed 's/ //g'
}

function TestGetAmountTestedFunctions() {
  TestShowFunctionNames | wc -l
}

function TestShowMeResults() {
  TestListFunctions 2&>/dev/null || echo "Não foi possível executar a função"

  local TestAmountDeclaredFunctions=$(TestCompareFunctionsCreateWithCalled | wc -l)
  local TestAmountCreatedFunctions=$(TestListFunctions | wc -l)

  if [ ${TestAmountDeclaredFunctions} -ne ${TestAmountCreatedFunctions} ]; then
    echo "Total funções declaradas: ${TestAmountDeclaredFunctions}"
    echo "Total funções criadas: ${TestAmountCreatedFunctions}"
    echo "Total funções testadas: $(TestGetAmountTestedFunctions)"
  fi
}

# Inicio dos testes das funçoes
function TestAWSGetCredentials() {
  AWSGetCredentials 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestAWSGetCredentialsAccessKey() {
  AWSGetCredentialsAccessKey 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestAWSGetCredentialsAccessKeyId() {
  AWSGetCredentialsAccessKeyId 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestAWSGetCredentialsCreateEnvVariableAccessKey() {
  AWSGetCredentialsCreateEnvVariableAccessKey 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestAWSGetCredentialsCreateEnvVariableAccessKeyId() {
  AWSGetCredentialsCreateEnvVariableAccessKeyId 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestAWSCloudfrontListAllById() {
  AWSCloudfrontListAllById 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# API Gateway
function TestAWSApiGatewayGetAll() {
  AWSApiGatewayGetAll 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSApiGatewayGetRestAPIs() {
  AWSApiGatewayGetRestAPIs 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSApiGatewayGetResources() {
  AWSApiGatewayGetResources 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSApiGatewayGetResourcesIntegrationRequests() {
  AWSApiGatewayGetResourcesIntegrationRequests 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# Secrets Manager
function TestAWSSecretsManagerListAll() {
  AWSSecretsManagerListAll 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSSecretsManagerListByName() {
  AWSSecretsManagerListByName 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSSecretsManagerListByTag() {
  AWSSecretsManagerListByTag 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSSecretsManagerDeleteForced() {
  AWSSecretsManagerDeleteForced 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# Helpers
function TestHelperGetPasswordArgoCD() {
  HelperGetPasswordArgoCD 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestHelperGetPasswordGrafana() {
  HelperGetPasswordGrafana 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestHelperGetPasswordDashboard() {
  HelperGetPasswordDashboard 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# Kubernetes
function TestKubernetesGetCurrentCluster() {
  KubernetesGetCurrentCluster 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestKubernetesGetCurrentNamespace() {
  KubernetesGetCurrentNamespace 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestKubernetesSetCurrentNamespace() {
  KubernetesSetCurrentNamespace 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestKubernetesListTopPodsBy() {
  KubernetesListTopPodsBy 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestKubernetesGetSpecificSecret() {
  KubernetesGetSpecificSecret 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestKubernetesGetAllSecrets() {
  KubernetesGetAllSecrets 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# EKS
function TestKubernetesSetCurrentCluster() {
  KubernetesSetCurrentCluster \
  cluster-1 \
  2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGenerateAuths() {
  AWSEKSGenerateAuths 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGetClusters() {
  AWSEKSGetClusters 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGetAmountClusters() {
  AWSEKSGetAmountClusters 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGetNodeGroupsByCluster() {
  AWSEKSGetNodeGroupsByCluster >/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSDescribeNodeGroupsByCluster() {
  AWSEKSDescribeNodeGroupsByCluster \
  cluster-1 \
  cluster-1-app-stl-20221010165302123100000019 \
  2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGetNodeGroupsInfos() {
  AWSEKSGetNodeGroupsInfos 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGetAmountNodes() {
  AWSEKSGetAmountNodes 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGetClusterVersion() {
  AWSEKSGetClusterVersion 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSGetAmountNodeGroups() {
  AWSEKSGetAmountNodeGroups 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSListNodeGroupsNamesByCluster() {
  AWSEKSListNodeGroupsNamesByCluster 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSEKSListNodesPerLabel() {
  AWSEKSListNodesPerLabel 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# OS
function TestOsCreateSSHKeys() {
  OsCreateSSHKeys 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestOsGetFreeMemory() {
  OsGetFreeMemory 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestOsGetTime() {
  OsGetTime 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestOsGetTimeUTC() {
  OsGetTimeUTC 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestOsCompareUTCWithBrazilianTime() {
  OsCompareUTCWithBrazilianTime 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestOsIsChristmasWeek() {
  OsIsChristmasWeek 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestOsPermissionSanitization() {
  OsPermissionSanitization 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestOsPermissionForFilesSanitization() {
  (
    cd /tmp

    OsPermissionSanitization f ${ENV_OS_DEFAULT_PERMISSION_FILES} -f >/dev/null

    TestSuccessOrFailMessage $? ${FUNCNAME[0]}
  )
}

function TestOsPermissionForDirectoriesSanitization() {
  (
    cd /tmp

    OsPermissionSanitization d ${ENV_OS_DEFAULT_PERMISSION_DIRECTORY} -f >/dev/null

    TestSuccessOrFailMessage $? ${FUNCNAME[0]}
  )
}

# RabbitMQ
function TestRabbitMQHelp() {
  RabbitMQHelp 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestRabbitMQCheckEnvironmentVariables() {
  RabbitMQCheckEnvironmentVariables 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestRabbitMQImportDefinitions() {
  RabbitMQImportDefinitions 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestRabbitMQGetUsers() {
  RabbitMQGetUsers 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestRabbitMQGetMessages() {
  RabbitMQGetMessages 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestRabbitMQGetExtensions() {
  RabbitMQGetExtensions 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestRabbitMQGetDefinitions() {
  RabbitMQGetDefinitions 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

# Terraform
function TestTerraformInitCommand() {
  TerraformInitCommand 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

function TestTerraformGetCurrentWorkspace() {
  TerraformGetCurrentWorkspace 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestTerraformSetVersion() {
  TerraformSetVersion 1.2.1 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestTerraformShowInstalledVersions() {
  TerraformShowInstalledVersions 2&>/dev/null >/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# Docker
function TestDockerIsThisDocker() {
  DockerIsThisDocker 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestDockerDind() {
  DockerIsThisDocker 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

# Git
function TestGitGetCurrentBranch() {
  GitGetCurrentBranch 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

#Lambdas
function TestAWSLambdaListFunctions() {
  AWSLambdaListFunctions 2&>/dev/null

  TestSuccessOrFailMessage $? ${FUNCNAME[0]}
}

function TestAWSLambdaInvokeFunction() {
  AWSLambdaInvokeFunction 2&>/dev/null && Success=0 || Success=1

  TestSuccessOrFailMessage ${Success} ${FUNCNAME[0]}
}

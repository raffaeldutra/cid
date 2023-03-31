# Funções para manipulação da AWS em CLI

# @function: AWSGetCredentials
# @description: Mostra suas credenciais
# @noargs
# @return: Text
# @exitcode 0 Sucesso
# @exitcode 1 Não for encontrado o arquivo necessário
function AWSGetCredentials() {
  if [ ! -e $HOME/.aws/credentials ]; then
    echo "${FUNCNAME[0]}: Arquivo $HOME/.aws/credentials não existe, saindo"

    return 1
  fi

  cat $HOME/.aws/credentials
}

# API Gateway
# @function: AWSApiGatewayGetAll
# @description: Lista os nomes de domínios vinculados no API Gateway
# @noargs
# @return: Text
# @exitcode 0 Sucesso
function AWSApiGatewayGetAll() {
  aws apigateway get-domain-names \
  --query "items[].[domainName,distributionDomainName,certificateArn,distributionHostedZoneId]" \
  --output json
}

# API Gateway
# @function: AWSApiGatewayGetRestAPIs
# @description: Lista todas REST APIs
# @noargs
# @return: Text
# @exitcode 0 Sucesso
function AWSApiGatewayGetRestAPIs() {
  aws apigateway get-rest-apis \
  --query 'items[].id' \
  --output text
}

# API Gateway
# @function: AWSApiGatewayGetResources
# @description: Lista os recursos do API Gateway
# @arg: AWSDirectory
# @return: List<String>
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSApiGatewayGetRestAPIs não foi encontrada
function AWSApiGatewayGetResources() {
  if [ "$(type -t AWSApiGatewayGetRestAPIs)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSApiGatewayGetRestAPIs não encontrada"

    return 1
  fi

  local AWSDirectory="/tmp/api-resources"

  mkdir -p ${AWSDirectory} 2>/dev/null

  for AWSAPIGatewayId in $(AWSApiGatewayGetRestAPIs); do
    local AWSFileApiResources="${AWSDirectory}/${AWSAPIGatewayId}-resources.json"

    echo "Listando API ${AWSAPIGatewayId}" >| ${AWSFileApiResources}
    aws apigateway get-resources \
    --rest-api-id ${AWSAPIGatewayId} \
    --query "items[].[id,path,pathPart,resourceMethods]" >> ${AWSFileApiResources}
    echo
  done
}

# @function: AWSApiGatewayGetResourcesIntegrationRequests
# @description: Resources do API Gateway enviando para um arquivo.
# @arg: AWSDirectory
# @return: Text
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSApiGatewayGetRestAPIs não foi encontrada
function AWSApiGatewayGetResourcesIntegrationRequests() {
  if [ "$(type -t AWSApiGatewayGetRestAPIs)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSApiGatewayGetRestAPIs não encontrada"

    return 1
  fi

  local AWSDirectory="/tmp/api-resources-integration-requests"

  mkdir -p ${AWSDirectory} 2>/dev/null

  for Id in $(AWSApiGatewayGetRestAPIs); do
    local FileOutput="${AWSDirectory}/${Id}-requests.json"

    for ResourceId in $(aws apigateway get-resources \
      --rest-api-id ${Id} \
      --query 'items[].id' \
      --output text); do
      aws apigateway get-integration \
      --rest-api-id ${Id} \
      --resource-id ${ResourceId} \
      --http-method GET 2>/dev/null > ${FileOutput}
    done
  done
}

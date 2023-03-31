# @function: AWSLambdaListFunctions
# @description: Lista todas as lambdas
# @noargs
# @return: List<String>
# @exitcode 0 Sucesso
function AWSLambdaListFunctions() {
  aws lambda list-functions \
  --query 'Functions[].FunctionName' \
  --output table
}

# @function: AWSLambdaInvokeFunction
# @description: Faz a chamada de uma determinada lambda
# @arg: AWSFunctionName
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro AWSFunctionName não foi definida
function AWSLambdaInvokeFunction() {
  local AWSFunctionName="${1}"

  if [ -z ${AWSFunctionName} ]; then
    echo "${FUNCNAME[0]}: Passe o nome da função para ser invocada"

    return 1
  fi

  aws lambda invoke \
  --function-name ${AWSFunctionName} \
  /tmp/${AWSFunctionName}.json
}

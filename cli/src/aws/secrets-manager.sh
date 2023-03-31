# Secrets Manager
# @function: AWSSecretsManagerListAll
# @description: Lista todas as secrets cadastradas no Secrets Manager
# @noargs
# @return: List<String>
# @exitcode 0 Sucesso
function AWSSecretsManagerListAll() {
  aws secretsmanager list-secrets
}

# @function: AWSSecretsManagerListByName
# @description: Lista todas as secrets cadastradas no Secrets Manager por nome
# @noargs
# @return: String
# @exitcode 0 Sucesso
function AWSSecretsManagerListByName() {
  AWSSecretsManagerListAll \
  --query SecretList[*].[Name] \
  --output text
}

# @function: AWSSecretsManagerListByTag
# @description: Lista chaves por tag.
# @arg: AWStagValue
# @return: List<String>
# @exitcode 0 Sucesso
# @exitcode 1 Não for informado parâmetro
# @exitcode 1 Parâmetro AWStagValue não foi definida
function AWSSecretsManagerListByTag() {
  local AWStagValue="${1}"

  if [ -z "${AWStagValue}" ]; then
    echo "${FUNCNAME[0]}: Passe uma nome do valor a ser consultado"

    exit 1
  fi

  aws secretsmanager list-secrets \
  --filter Key=tag-value,Values="${AWStagValue}"
}

# @function: AWSSecretsManagerDeleteForced
# @description: Deleta chave na marretada.
# @arg: AWSSecretId
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Não for informado parâmetro
# @exitcode 1 Parâmetro AWSSecretId não foi definida
function AWSSecretsManagerDeleteForced() {
  local AWSSecretId="${1}"

  if [ -z "${AWSSecretId}" ]; then
    echo "${FUNCNAME[0]}: Passe o nome da secret a ser deletada"

    exit 1
  fi

  aws secretsmanager delete-secret \
  --secret-id ${AWSSecretId} \
  --force-delete-without-recovery
}

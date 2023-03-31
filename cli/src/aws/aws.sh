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

# @function: AWSGetCredentialsAccessKeyId
# @description: Mostra o ID da sua conta
# @noargs
# @return: Text
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSGetCredentials não foi encontrada
function AWSGetCredentialsAccessKeyId() {
  if [ "$(type -t AWSGetCredentials)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSGetCredentials não encontrada"

    return 1
  fi

  AWSGetCredentials | \
  grep -A2 ${ENV_PREFIX} | \
  sed '1d' | \
  grep "aws_access_key_id" | \
  cut -d "=" -f2
}

# @function: AWSGetCredentialsAccessKey
# @description: Mostra suas credenciais
# @noargs
# @return: Text
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSGetCredentials não foi encontrada
function AWSGetCredentialsAccessKey() {
  if [ "$(type -t AWSGetCredentials)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSGetCredentials não encontrada"

    return 1
  fi

  AWSGetCredentials | \
  grep -A2 ${ENV_PREFIX} | \
  sed '1d' | \
  grep "aws_secret_access_key" | \
  cut -d "=" -f2
}

# @function: AWSGetCredentialsCreateEnvVariableAccessKeyId
# @description: Cria a variável de ambiente AWS_ACCESS_KEY_ID
# @noargs
# @return: Text
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSGetCredentialsAccessKeyId não foi encontrada
function AWSGetCredentialsCreateEnvVariableAccessKeyId() {
  if [ "$(type -t AWSGetCredentialsAccessKeyId)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSGetCredentialsAccessKeyId não encontrada"

    return 1
  fi

  export AWS_ACCESS_KEY_ID=$(AWSGetCredentialsAccessKeyId)
}

# @function: AWSGetCredentialsCreateEnvVariableAccessKey
# @description: Cria a variável de ambiente AWS_SECRET_ACCESS_KEY
# @noargs
# @return: Text
# @exitcode 0 Sucesso
# @exitcode 1 Função AWSGetCredentialsAccessKey não foi encontrada
function AWSGetCredentialsCreateEnvVariableAccessKey() {
  if [ "$(type -t AWSGetCredentialsAccessKey)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função AWSGetCredentialsAccessKey não encontrada"

    return 1
  fi

  export AWS_SECRET_ACCESS_KEY=$(AWSGetCredentialsAccessKey)
}

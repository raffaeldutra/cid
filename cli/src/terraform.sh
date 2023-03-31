declare TerraformVersionsPath="/app/terraform-versions"

# @function: TerraformInitCommand
# @description: Reposável por mostrar o comando terraform init já formato para os ambientes.
# @description: Apenas mostrará o comando caso o provider de cloud selecionado for contemplado na construção do comando.
# @description: Retorna o comando pronto para todas as contas que estão cadastradas em ~/.aws/credentials.
# @description: Filtra apenas as credenciais removendo o cabeçalho retornado pelo -A2
# @noargs
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro AWSGetCredentials não foi definido.
# @exitcode 1 Função AWSGetCredentials não foi encontrada.
function TerraformInitCommand() {
  # Conforme mais providers aparecerem, esta função deve ser novamente implentada para o provider selecionado.
  # Quando houverem outros providers, alterar as condições para um case no lugar de if.
  # O bloco abaixo é para AWS apenas.
  if [[ ${ENV_CONFIG_TOOLS[*]} =~ "aws" ]]; then
    if [ "$(type -t AWSGetCredentials)" != "function" ]; then
      echo "${FUNCNAME[0]}: Função AWSGetCredentials não encontrada"

      return 1
    fi

    AWSGetCredentials | \
    grep -v "^#" | \
    grep "\[*\]" | \
    tr -d '[]' | \
    grep "${CLIENT_NAME}" | \
    while read Account; do
      echo; echo "${_GREEN}Terraform init: ${_RESET}${_RED}${Account}${_RESET}"

      TerraformAWSAccessKeyId=$(AWSGetCredentials | \
      grep -A2 ${Account} | \
      sed '1d' | \
      grep "aws_access_key_id" | \
      cut -d "=" -f2)

      TerraformAWSSecretAccessKey=$(AWSGetCredentials | \
      grep -A2 ${Account} | \
      sed '1d' | \
      grep "aws_secret_access_key" | \
      cut -d "=" -f2)

      cat <<<'
      terraform init \
      -backend-config="access_key=${TerraformAWSAccessKeyId}" \
      -backend-config="secret_key=${TerraformAWSSecretAccessKey}" \
      -backend-config="region=us-east-1" \
      -backend-config="profile=${Account}'
    done
  else
    echo "Provider não existe ou não foi fornecido no arquivo .env.config"
  fi
}

# @function: TerraformInstall
# @description: Retorna todas versões que foram instalados no container na variável global TerraformVersionsPath declarada.
# @arg: TerraformArchitecture
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro TerraformVersion não foi definido
function TerraformInstall() {
  local TerraformArchitecture="amd64"

  if [ "${TerraformArchitecture}" == "aarch64" ]; then
    local TerraformArchitecture="arm64"
  fi

  local TerraformVersion="${1}"

  if [ -z ${TerraformVersion} ]; then
    echo "${FUNCNAME[0]}: Versão do Terraform não identificada"

    return 1
  fi

  local TerraformPackage="terraform_${TerraformVersion}_linux_${TerraformArchitecture}.zip"

  # Caso não existir ainda o diretório da versão selecionado, será criado.
  mkdir -p ${TerraformVersionsPath}/${TerraformVersion}

  (
    cd ${TerraformVersionsPath}/${TerraformVersion}
    wget https://releases.hashicorp.com/terraform/${TerraformVersion}/${TerraformPackage}
    unzip -q ${TerraformPackage}

    rm ${TerraformPackage}
  )
}

# @function: TerraformVersionExists
# @description: Caso não seja encontrado o binário do Terraform, é feito o download na versão do arquivo versions.tf.
# @arg: TerraformVersion
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Versão do Terraform não for especificada.
function TerraformVersionExists() {
  if [ "$(type -t TerraformInstall)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função TerraformInstall não encontrada"

    return 1
  fi

  local TerraformVersion="${1}"

  if [ -z ${TerraformVersion} ]; then
    echo "${FUNCNAME[0]}: Versão do Terraform não identificada"

    return 1
  fi

  # Se não existir o binário para a versão selecionada, chama a função para instalação do Terraform.
  if [ ! -e "${TerraformVersionsPath}/${TerraformVersion}/terraform" ]; then
    TerraformInstall ${TerraformVersion}
  fi
}

# @function: TerraformShowInstalledVersions
# @description: Retorna todas versões que foram instalados no container na variável global TerraformVersionsPath declarada.
# @noargs
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Se o path não existe.
function TerraformShowInstalledVersions() {
  if [ ! -e "${TerraformVersionsPath}" ]; then
    echo "${FUNCNAME[0]}: Path não encontrado, verifique."

    return 1
  fi

  ls -1 ${TerraformVersionsPath}
}

# @function: TerraformSetVersion
# @description: Seta a versão do Terraform solicitada, caso não for encontrada a versão solicitada será baixada.
# @arg: TerraformVersion
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Se o path não existe.
function TerraformSetVersion() {
  if [ "$(type -t TerraformInstall)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função TerraformInstall não encontrada"

    return 1
  fi

  local TerraformVersion="${1}"

  if [ -z "${TerraformVersion}" ]; then
    echo "${FUNCNAME[0]}: Versão do Terraform não setada"

    return 1
  fi

  TerraformVersionExists ${TerraformVersion}

  ln -sf ${TerraformVersionsPath}/${TerraformVersion}/terraform /app/terraform
}

# @function: TerraformGetCurrentWorkspace
# @description: Seta a versão do Terraform solicitada, caso não for encontrada a versão solicitada será baixada.
# @noargs
# @return: void
# @exitcode 0 Sucesso
function TerraformGetCurrentWorkspace() {
  if [ "$(type -t TerraformInstall)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função TerraformInstall não encontrada"

    return 1
  fi

  if [ "$(type -t TerraformSetVersion)" != "function" ]; then
    echo "${FUNCNAME[0]}: Função TerraformSetVersion não encontrada"

    return 1
  fi

  if [ -e ".terraform" -a -e "versions.tf" ]; then
    local TerraformVersion="$(
      cat versions.tf | \
      grep required_version | \
      cut -d "=" -f2- | \
      sed -e 's/[ "\,\r$\s>=]//g'
    )"

    # Caso não seja encontrado o binário do Terraform, é feito o download na versão do arquivo versions.tf.
    if [ ! -e "${TerraformVersionsPath}/${TerraformVersion}/terraform" ]; then
      TerraformInstall ${TerraformVersion}
    fi

    # Cria o atalho para a versão correspondente.
    TerraformSetVersion ${TerraformVersion}

    local TerraformWorkspace=$(terraform workspace show)

    if [ "x${TerraformVersion}" != "x" ]; then
      echo -en "| (tw:${TerraformWorkspace}|v:${TerraformVersion})"
    else
      echo "| (tw:${TerraformWorkspace}|v:${_RED}NF${_RESET}))"
      echo -n "(fix me) file versions.tf exists but ${_RED}Terraform version${_RESET} is missing"
    fi
  fi
}

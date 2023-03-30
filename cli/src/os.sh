# @function: OsCreateSSHKeys
# @description: Criar chaves ssh
# @noargs
# @return: Text<SSH>
# @exitcode 0 Sucesso
# @exitcode 1 Quando chaves escolhidas para serem geradas já existem
function OsCreateSSHKeys() {
  local OSDirectory=${1}

  if [ -z ${OSDirectory} ]; then
    echo "Não foi informado o nome da chave a ser criado."
    echo "Exemplo: ${CLI_ALIAS} -osssh <chave>"
  fi

  if [ ! -d "${HOME}/.ssh/${OSDirectory}" ]; then
    mkdir -p "${HOME}/.ssh/${OSDirectory}"
    ssh-keygen -t rsa -b 4096 -f ${HOME}/.ssh/${OSDirectory}/id_rsa -q -N ""
    chmod 400 ${HOME}/.ssh/${OSDirectory}/id_rsa

    echo "Aqui esta a chave SSH publica para ${OSDirectory}"
    cat ${HOME}/.ssh/${OSDirectory}/id_rsa.pub
  else
    echo "Chaves já existem, saindo em ${HOME}/.ssh/${OSDirectory}"

    return 1
  fi
}

# @function: OsGetFreeMemory
# @description: Retorna em MB a quantidade de memória livre deste container
# @description: Recebe como valor a variável ENV_CONTAINER_MINIMUM_MEMORY definida em .env.config
# @noargs
# @return: Number<MB>
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro ENV_CONTAINER_MINIMUM_MEMORY não definido em .env.config
function OsGetFreeMemory() {
  if [ -z ${ENV_CONTAINER_MINIMUM_MEMORY} ]; then
    echo "Parâmetro ENV_CONTAINER_MINIMUM_MEMORY não definido. Procure em .env.config pelo valor"

    return 1
  fi

  source /etc/os-release
  if [ "${NAME}" == "Ubuntu" -o "${NAME}" == "Debian" ]; then
    local OSMemoryInBytesUsage=$(cat /sys/fs/cgroup/memory.current)
    local OSMemoryInBytesLimit=$(cat /sys/fs/cgroup/memory.max)
  elif [ "${NAME}" == "Alpine" ]; then
    local OSMemoryInBytesLimit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
    local OSMemoryInBytesUsage=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes)
  else
    echo "Não foi possível fazer o calculo pois não foi possível detectar o OS utilizado, saindo"

    exit 1
  fi

  local OSCalcFreeMemoryInMegabytes="(${OSMemoryInBytesLimit}/1024/1024 - ${OSMemoryInBytesUsage}/1024/1024)"
  local OSCalcFreeMemory="$(echo ${OSCalcFreeMemoryInMegabytes} | bc)"

  if [ ${OSCalcFreeMemory} -lt ${ENV_CONTAINER_MINIMUM_MEMORY} ]; then
    local OSCalcFreeMemory="${_RED}${OSCalcFreeMemory}${_RESET}"
  fi

  echo "FM:${OSCalcFreeMemory}"
}

# @function: OsGetTime
# @description: Retorna o horário corrente em formato Hora:Minuto:Segundo para UTC -0300
# @noargs
# @return: String
# @exitcode 0 Sucesso
function OsGetTime() {
  date +%H:%M:%S
}

# @function: OsGetTimeUTC
# @description: Retorna o horário corrente em formato Hora:Minuto:Segundo para UTC 0000
# @noargs
# @return: String
# @exitcode 0 Sucesso
function OsGetTimeUTC() {
  date -u +%H:%M:%S
}

# @function: OsGetTimeUTC
# @description: Compara horário UTC -0300 com UTC 0000
# @noargs
# @return: String
# @exitcode 0 Sucesso
function OsCompareUTCWithBrazilianTime() {
  echo " UTC: $(OsGetTimeUTC)"
  echo "0300: $(OsGetTime)"
}

# @function: OSGetDateYYYYMMDD
# @description: Retorna a data em formato YYYY-MM-DD
# @noargs
# @return: String
# @exitcode 0 Sucesso
function OSGetDateYYYYMMDD() {
  echo $(date -d $(date +%Y-%m-%d) +%s)
}

# @function: OSGetDate
# @description: Retorna a data no formato yyy-mm-dd
# @noargs
# @return: String
# @exitcode 0 Sucesso
function OSGetDate() {
  date +%Y-%m-%d
}

# @function: OsIsChristmasWeek
# @description: Verifica se estamos na semana do Natal
# @arg: ENV_OS_CHRISTMAS_START
# @arg: ENV_OS_CHRISTMAS_END
# @return: void
# @exitcode 0 Sucesso
function OsIsChristmasWeek() {
  local OSChristmasStart=$(date -d $(date +%Y)-${ENV_OS_CHRISTMAS_MONTH}-${ENV_OS_CHRISTMAS_START} +%s)
  local OSChristmasEnd=$(date -d $(date +%Y)-${ENV_OS_CHRISTMAS_MONTH}-${ENV_OS_CHRISTMAS_END} +%s)

  if [ ${OSChristmasStart} -le ${OSChristmasEnd} -a \
      $(OSGetDateYYYYMMDD) -ge ${OSChristmasStart} -a \
      $(OSGetDateYYYYMMDD) -le ${OSChristmasEnd} ]; then

    StartEmoji="\\U1F332" # Papai Noel
    EndEmoji="\\U1F385"   # Arvore
  else
    StartEmoji="\\U1F60D" # Love
    EndEmoji="\\U1F60E"   # Oculos
  fi
}

# @function: OsPermissionSanitization
# @description: Seta a permissão que é solicitada via argumento
# @description: Seta permissões padrão para arquivos, pra quem usa Windows
# @arg: OSObject
# @arg: OSChmod
# @arg: OSForce
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro OSObject não foi definido
# @exitcode 1 Parâmetro OSChmod não foi definido
# @exitcode 1 Parâmetro OSForce não foi definido
function OsPermissionSanitization() {
  local OSObject=${1}
  local OSChmod=${2}
  local OSForce=${3}

  if [ -z ${OSObject} -o -z ${OSChmod} ]; then
    echo "Passe os dois argumentos necessários: [Object] e [Key]"

    return 1
  fi

  if [ -n "${OSForce}" -a "${OSForce}" == "-f" ]; then
    local OSOption="yes"
  else
    read -p "Setando permissão para ${OSChmod}, tem certeza?: " OSOption
  fi

  for OSAllowedPermissions in yes y sim s yeap; do
    if [ ${OSOption} == "${OSAllowedPermissions}" ]; then
      echo "Aguarde..."
      find . -type ${OSObject} -exec chmod ${OSChmod} {} \;
    fi
  done
}

# @function: OsPermissionForFilesSanitization
# @description: Seta permissões para arquivos
# @arg: ENV_OS_DEFAULT_PERMISSION_FILES
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro ENV_OS_DEFAULT_PERMISSION_DIRECTORY não definido em .env.config
function OsPermissionSanitizationForFiles() {
  if [ -z ${ENV_OS_DEFAULT_PERMISSION_FILES} ]; then
    echo "Parâmetro ENV_OS_DEFAULT_PERMISSION_FILES não definido."
    echo "Procure em .env.config pelo valor."

    return 1
  fi

  OsPermissionSanitization f ${ENV_OS_DEFAULT_PERMISSION_FILES}
}

# @function: OsPermissionForDirectoriesSanitization
# @description: Permissionamento para diretórios
# @arg: ENV_OS_DEFAULT_PERMISSION_DIRECTORY
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro ENV_OS_DEFAULT_PERMISSION_DIRECTORY não definido em .env.config
function OsPermissionSanitizationForDirectories() {
  if [ -z ${ENV_OS_DEFAULT_PERMISSION_DIRECTORY} ]; then
    echo "Parâmetro ENV_OS_DEFAULT_PERMISSION_DIRECTORY não definido."
    echo "Procure em .env.config pelo valor."

    return 1
  fi

  OsPermissionSanitization d ${ENV_OS_DEFAULT_PERMISSION_DIRECTORY}
}

# @function: OsDetectOS
# @description: Retorna o OS que está sendo utilizado
# @noargs
# @return: String
# @exitcode 0 Sucesso
function OsDetectOS() {
  case "$(uname -sr)" in
    Darwin*)                       echo "Mac";;
    Linux*Microsoft*)              echo "WSL";;
    Linux*)                        echo "Linux" ;;
    CYGWIN*|MINGW*|MINGW32*|MSYS*) echo "Windows" ;;
    *)                             echo "Other" ;;
  esac
}

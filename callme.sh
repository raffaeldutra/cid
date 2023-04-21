#!/usr/bin/env bash

set -e

# Chama o script que faz a instalação para ver se o ambiente está todo de acordo para
# poder rodar plenamente.
bash install/install.sh -check

source $(pwd)/.env.config
source $(pwd)/cli/src/docker.sh
source $(pwd)/cli/src/git.sh
source $(pwd)/cli/src/os.sh
source $(pwd)/cli/src/misc.sh

export ARCH="$(arch)"

if [ -n "${ENV_DOCKERFILE_ARCH}" ]; then
  export ARCH=${ENV_DOCKERFILE_ARCH}
fi

function ContainersClientGetList() {
  local ClientName="${1}"

  if [ -z "${ClientName}" ]; then
    echo "Nome do cliente não foi definido, saindo"

    exit 1
  fi

  grep "container_name:" clients/${ClientName}/${ClientName}.containers.yml | \
  awk '{print $2}' | \
  grep -v docker-template
}

# A função OsDetectOS detecta o sistema operacional em que o script está sendo executado. A função utiliza o comando uname
# para verificar o nome do sistema e retorna uma das seguintes opções: Windows, Linux ou Mac. Caso a detecção não seja
# bem-sucedida, a função retorna uma string vazia.
if [ "$(OsDetectOS)" == "Windows" ]; then
  echo "Desculpe, mas o ambiente só funciona em Sistema Operacional, saindo."

  exit 1
fi

# Caso o sistema operacional detectado seja o Linux, o script verifica se o comando dialog está instalado no sistema. Caso não
# esteja, o script utiliza o gerenciador de pacotes apt-get para instalar o dialog. Caso o gerenciador de pacotes não esteja
# instalado ou ocorra algum erro na instalação do dialog, o script exibe uma mensagem de erro informando que a "Família Linux
#não foi encontrada" e encerra.
if [ "$(OsDetectOS)" == "Linux" ]; then
  $(which dialog) || ($(which apt-get >/dev/null) && (apt-get update --yes && apt-get install --yes dialog) || echo "Familia Linux não encontrada, saindo")
fi

# Caso o sistema operacional detectado seja o Mac, o script verifica se o comando dialog está instalado no sistema. Caso não esteja,
# o script utiliza o gerenciador de pacotes brew para instalar o dialog. Caso o gerenciador de pacotes não esteja instalado ou ocorra
# algum erro na instalação do dialog, o script exibe uma mensagem de erro informando que o "Brew não foi encontrado" e encerra
if [ "$(OsDetectOS)" == "Mac" ]; then
  $(which dialog >/dev/null) || ($(which brew >/dev/null) && brew install dialog || echo "Brew não encontrado, saindo")
fi

# Caso a variável booleana JOKE_CHUCK_NORRIS seja definida como verdadeira, o script exibe uma caixa de diálogo com uma piada
# do Chuck Norris. A piada é gerada pela função JokeChuckNorris. Em seguida, o script aguarda por 10 segundos antes de continuar
if [ ${JOKE_CHUCK_NORRIS} = true ]; then
  dialog \
  --title "Chuck Jokes" \
  --infobox "$(JokeChuckNorris)" \
  0 0

  sleep 10
fi

# Opção para a parte superior do diaglo trazendo informações do último commit caso tenha.
if [ $(GitGetLastCommitShort) ]; then
  declare DialogBackTitle=$(echo "Último commit: $(GitGetLastCommitShort) por $(GitGetLastCommitAuthorName) em $(GitGetLastCommitDate)")
else
  declare DialogBackTitle="Commit ainda não identificado"
fi

declare DialogTitle="Ambiente de desenvolvimento em containers"
declare DialogHeight=0
declare DialogWidth=45

# O script possui um laço for que percorre os arquivos dentro da pasta "clients". Para cada arquivo encontrado, o script adiciona
# o nome do arquivo em um array ClientsNames e um índice numérico correspondente em outro array ClientsNames.
declare -a ClientsNames=()
declare ClientIndex=1

# O array ClientsNames é utilizado para armazenar os nomes dos clientes encontrados na pasta "clients" e seus índices numéricos
# correspondentes. Na primeira linha, o índice numérico é adicionado ao array utilizando o operador +=.
# Na segunda linha, o nome do cliente é adicionado ao array utilizando novamente o operador +=. O nome do cliente é obtido a
# partir da variável ClientNameOptionMenu, que contém o nome do arquivo.
for ClientNameOptionMenu in $(ls -1 clients); do
  ClientsNames+=("${ClientIndex}")
  ClientsNames+=("${ClientNameOptionMenu}")
  ((ClientIndex=ClientIndex+1))
done

# O comando dialog é utilizado para criar um menu de seleção de clientes. O menu apresenta uma lista de opções correspondentes aos
# clientes encontrados na pasta "clients". O nome do cliente e seu índice numérico correspondente são obtidos a partir do array
# ClientsNames. A escolha do usuário é armazenada na variável ClientNameOption
ClientNameOption=$(
  dialog \
  --no-cancel \
  --backtitle "${DialogBackTitle}" \
  --title "${DialogTitle}" \
  --menu "Escolha o cliente desejado abaixo" \
  ${DialogHeight} ${DialogWidth} 0 \
  ${ClientsNames[@]} \
  ${ClientIndex} "Sair" 2>&1 >/dev/tty
)

# Se opção escolhida foi para sair
if [ ${ClientNameOption} -eq ${ClientIndex} ]; then
  exit 1
fi

# A variável ClientNameSelected é utilizada para armazenar o índice do nome do cliente selecionado no array ClientsNames.
# O índice é obtido a partir da opção selecionada pelo usuário armazenada na variável ClientNameOption. Para obter o índice
# do nome correto, é preciso multiplicar ClientNameOption por 2 e subtrair 1.
declare ClientNameSelected=$(((${ClientNameOption} * 2) - 1))
declare ClientPath="$(pwd)/clients/${ClientName}"
declare ClientName=${ClientsNames[${ClientNameSelected}]}

# Submenu para o cliente selecionado
declare ClientIndex=1
declare -a ContainersList=()

# BASH não tem array associativo, portanto tivemos que gerar um array em formato pares para que o menu apresentasse
# de forma adequada as opções que desejamos, ou seja, ClientIndex=1 e o proximo valor será o nome do cliente/container
# ficando com o formato: array-(1 empresa1 2 empresa 3 empresa3 4 empresa4) e mesma coisa vale para os containers que
# são gerados de forma dinâmica
for Container in $(ContainersClientGetList ${ClientName}); do
  ContainersList+=("${ClientIndex}")
  ContainersList+=("${Container}")
  ((ClientIndex=ClientIndex+1))
done

declare ClientNameContainer=$(dialog \
--no-cancel \
--backtitle "${DialogBackTitle}" \
--title "${DialogTitle}" \
--menu "Listando containers para o cliente ${ClientName}" \
${DialogHeight} ${DialogWidth} 0 \
${ContainersList[@]} \
- ---------- \
${ClientIndex} "Sair" 2>&1 >/dev/tty)

if [ ${ClientNameContainer} -eq ${ClientIndex} ]; then
  exit 1
fi

declare ClientNameContainerSelected=$(((${ClientNameContainer} * 2) - 1))
declare ClientNameContainerName=${ContainersList[${ClientNameContainerSelected}]}

if [ "${ClientNameContainerName}" == "docs" ]; then
  docker compose \
  -f ${ClientPath}/${ClientName}/${ClientName}.containers.yml \
  --env-file=${ClientPath}/${ClientName}/.env.common \
  --build docs
else
  docker compose \
  -f ${ClientPath}/${ClientName}/${ClientName}.secrets.yml \
  -f ${ClientPath}/${ClientName}/${ClientName}.containers.yml \
  --env-file=${ClientPath}/${ClientName}/.env.common \
  run ${ClientNameContainerName}
fi

#reset

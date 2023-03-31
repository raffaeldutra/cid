# @function: DockerIsThisDocker
# @description: Verifica se onde está sendo executada a função está dentro de Docker
# @noargs
# @return: Boolean
# @exitcode 0 Sucesso
function DockerIsThisDocker() {
  if [ -f /.dockerenv ]; then
    return 0
  fi

  return 1
}

# @function: DockerIsThisDockerMessage
# @description: Retorna apenas uma mensagem dizendo se o ambiente é Docker
# @noargs
# @return: String
# @exitcode 0 Sucesso
# @exitcode 1 Função DockerIsThisDocker não foi encontrada
function DockerIsThisDockerMessage() {
  if [ $(DockerIsThisDocker) -eq 1 ]; then
    echo "${FUNCNAME[0]}: Não consigo identificar uma instalação de Docker neste ambiente, saindo"

    return 1
  fi

  if [ $(DockerIsThisDocker) -eq 0 ]; then
    echo "Docker:T"
  else
    echo "Docker:F"
  fi
}

# @function: DockerInDocker
# @description: Abre um container dentro de container
# @noargs
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Falha
function DockerInDocker() {
  if [ $(DockerIsThisDocker) -eq 1 ]; then
    echo "${FUNCNAME[0]}: Não consigo identificar uma instalação de Docker neste ambiente, saindo"

    return 1
  fi

  docker container run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged docker \
  /bin/sh -c "apk add bash && /bin/bash"
}

# @function: DockerImageSize
# @description: Mostra o tamanho da imagem gerada para o cliente
# @noargs
# @return: void
# @exitcode 0 Sucesso
# @exitcode 1 Falha
function DockerClientImageSize() {
  if [ $(DockerIsThisDocker) ]; then
    echo "${FUNCNAME[0]}: Não consigo identificar uma instalação de Docker neste ambiente, saindo"

    return 1
  fi

  docker image ls | \
  grep ${CLIENT_NAME}/base-tools | \
  grep -v shared | \
  awk '{print $7}'
}

# @function: DockerSearchImage
# @description: Procura a imagem solicitada, caso não encontrar retorna status 1
# @arg: DockerImageName
# @return: Boolean
# @exitcode 0 Sucesso
# @exitcode 1 Parâmetro DockerImageName não foi definida
function DockerSearchImage() {
  local DockerImageName=${1}

  if [ -z ${DockerImageName} ]; then
    echo "${FUNCNAME[0]}: Variável não foi definida, saindo"

    return 1
  fi

  docker image ls | \
  grep ${DockerImageName} | \
  awk '{print $1}'
}

# @function: HelperDockerGetTag
# @description: Faz a pesquisa de tags para umde determinada imagem
# @noargs
# @return: List<String>
# @exitcode 0 Sucesso
function DockerGetTag() {
  local Repository=library
  local Arch="amd64*"
  local OS=linux
  local MaxPages=10
  local Quantity=40
  local Cache=0

  if [ $# -eq 0 ]; then
    echo "Diga qual imagem deseja procurar"
    exit 0
  fi

  Image=$1

  echo "Aguarde..."

  (
    url="https://registry.hub.docker.com/v2/repositories/${Repository}/${Image}/tags/?page_size=100"
    counter=1
    while [ $counter -le ${MaxPages} ] && [ -n "${url}" ]; do
      if [ ${Cache} -eq 0 ]; then
        content=$(curl --silent "${url}")
      else
        content=$(cache -e ${CACHE} -- curl --silent "${url}")
      fi
      ((counter++))
      url=$(jq -r '.next // empty' <<< "${content}")
      echo -n "${content}"
    done
  ) | jq -s '[.[].results[]]' \
    | jq 'map({tag: .name, image: .images[] | select(.architecture|match("'${Arch}'")) | select(.os|match("'${OS}'"))}) | map({tag: .tag}) | unique | sort_by(.tag)' \
    | jq -c '.[].tag' | \
    tail -n ${Quantity}
}

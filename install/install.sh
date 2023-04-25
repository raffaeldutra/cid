#!/usr/bin/env bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -e

# O script é responsável por instalar e realizar verificações em um sistema compartilhado.
# O script recebe um argumento passado na linha de comando, através da variável $1. Em seguida, ele verifica qual
# opção foi selecionada e executa a ação.

# Opções disponíveis:
# -run: inicia a instalação do sistema compartilhado.
# -dg: realiza o download de projetos do Git.
# -check: faz a verificação dos arquivos de configuração necessários.
# -h ou --help: mostra ajuda sobre as opções disponíveis.

# Funções:
# help: função responsável por mostrar a ajuda sobre as opções disponíveis.
# spin: função responsável por imprimir uma animação de "loading".
# InstallSuccessOrFailMessage: função que recebe um código de status como parâmetro e retorna uma mensagem de sucesso
# ou falha para ser exibida na saída do terminal.
# InstallSystemVerifyFiles: função que verifica se os arquivos do sistema compartilhado existem.
# InstallCreateMandatoryDirectories: função que cria os diretórios necessários para a instalação do sistema.

# Utilização:
# ./script.sh [opção]

# No caso da opção -run, pergunta ao usuário se deseja continuar com a instalação. Se a resposta for negativa, o script é
# encerrado com o código de saída 1. Caso contrário, o script clona o projeto Git do repositório especificado na variável
# ${InstallGitlabNamespaceProject}/${InstallProjectName} para o diretório ${InstallPathDevelopment} e cria o diretório
# ${InstallPathCredentials}.
#
# Em seguida, o script chama as seguintes funções:
# InstallSystemVerifyFiles
# InstallCreateMandatoryDirectories
#
# Caso haja algum erro em uma dessas funções, o código de erro é armazenado em um array.
#
# Ao final do processo, se houver erros registrados, o script exibe as mensagens correspondentes de acordo com o código de
# erro registrado. Se não houver erros, o script encerra com sucesso.
#
# A opção -h ou --help mostra ajuda sobre as opções disponíveis através da função help. Se o argumento passado não corresponder
# a nenhuma opção válida, o script também chama a função help.

# Cores para terminal
_RED=$(tput setaf 1)
_GREEN=$(tput setaf 2)
_YELLOW=$(tput setaf 3)
_BLUE=$(tput setaf 4)
_MAGENTA=$(tput setaf 5)
_CYAN=$(tput setaf 6)
_WHYTE=$(tput setaf 7)
_RESET=$(tput sgr0)
_BOLD=$(tput bold)

source $(pwd)/cli/src/os.sh

# Pede para inserir o nome do cliente que este instalador irá realizar, assim é possível utilizar
# em mais de um cliente se for necessário, apenas informar na CLI.
declare ClientName="${1}"

# Onde ficará a instalação do projeto para criar os diretórios e demais arquivos.
# Dê uma olhada na function help() para saber um pouco mais de detalhes
declare ClientDirectoryInstallation="${2}"

if [ -z "${ClientName}" ]; then
  echo "Você deve informar o nome do cliente que deseja fazer instalação, saindo."

  exit 1
fi

# Definição de onde será a raiz do projeto.
# Por padrão é assumido o $HOME de cada OS + Nome do Cliente passado via parâmetro + diretório chamado
# de development.
declare InstallPathDevelopment="${HOME}/${ClientName}/development"

# Se for passado como parâmetro um outro local para fazer a configuração, será usado.
if [ -n "${ClientDirectoryInstallation}" ]; then
  declare InstallPathDevelopment="${ClientDirectoryInstallation}"
fi

# Este é o nome do diretório que ao fazer clone irá existir na sua máquina.
# Mantemos ela em variável apenas para evitar reescritas de código aqui no instalador.
InstallProjectName="cid"

# Local de onde está o diretório de scaffolding para cópia dos arquivos template quando não hoiver
# em sua máquina. Este diretório encontra-se na raiz do projeto ${InstallProjectName}.
InstallPathScaffolding=${InstallPathDevelopment}/${InstallProjectName}/scaffolding

# Local de onde está o diretório de scaffolding para cópia dos arquivos template quando não hoiver
# Grafana é um exemplo que é necessário variáveis de ambiente.
# Terraform é um exemplo que necessita autenticação no Gitlab para puxar módulos.
InstallPathScaffoldingCredentials=${InstallPathScaffolding}/.credentials

# Local onde será gravado informações de segredos quando houver serviços que necessitam do uso.
# Este diretório não será commitado.
InstallPathSecrets=${InstallPathDevelopment}/${InstallProjectName}/.credentials/secrets
InstallPathEnvironment=${InstallPathDevelopment}/${InstallProjectName}/.credentials/env

help() {
cat << EOT
${_RED}Atenção caso seja sua primeira instalação.${_RESET}

O instalador irá criar a estrutrua de diretórios em ${_CYAN}${InstallPathDevelopment}${_RESET}
.
├── docs
├── ${InstallProjectName}
├── projects
└── terraform
EOT
}

# Arquivos que são usados no modelo "shared", ou seja, são/podem ser utilizados juntamente com o nosso ambiente
# de desenvolvimento, se mais arquivos forem utilizados, faça a verificação deles aqui nesta função.
function InstallSystemVerifyFiles() {
  if [ ! -e "$(pwd)/.env.config" -o ! -f "$(pwd)/.env.config" ]; then
    echo "Arquivo .env.config não encontrado, saindo"

    exit 1
  fi

  # Verifica se existe diretorio ssh
  if [ -d $HOME/.ssh ]; then
    find $HOME/.ssh -type f -exec chmod 400 {} \;
  else
    echo "Verifique o diretório ${HOME}/.ssh da sua máquina"

    exit 1
  fi

  if [[ ${ENV_CONFIG_TOOLS[*]} =~ "aws" ]]; then
    if [ ! -f "$(pwd)/.credentials/secrets/aws.dev" -o ! -e "$(pwd)/.credentials/secrets/aws.dev" ]; then
      echo "Não encontrei as credentials para aws"

      exit 1
    fi
  fi
}

# Verifica se existe o diretório .credentials para receber arquivos com variáveis de ambiente. Estes
# arquivos são necessários para poder comunicar com algum tipo de serviço.
function InstallCreateMandatoryDirectories() {
  for ProjectsDirectories in \
    "${InstallPathDevelopment}/../projects" \
    "${InstallPathDevelopment}/../terraform"; do

    if [ ! -e ${ProjectsDirectories} ]; then
      echo "Criando o diretório ${ProjectsDirectories}"

      mkdir -p  ${ProjectsDirectories}
    fi
  done

  return 0
}

function spin()
{
  Spinner="/|\\-/|\\-"

  for i in $(seq 0 10); do
    echo -n "${Spinner:$i:1}"
    echo -en "\010"
    sleep 0.2

    let i=i+1
  done
}

function InstallSystemDialog() {
  if [ "$(OsDetectOS)" == "Windows" ]; then
    echo "Desculpe, mas o ambiente só funciona em Sistema Operacional, saindo."

    exit 1
  elif [ "$(OsDetectOS)" == "Linux" ]; then
    if ! [ -x "$(command -v dialog)" ]; then
      apt-get update --yes
      apt-get install --yes dialog
    fi
  elif [ "$(OsDetectOS)" == "Mac" ]; then
    if ! [ -x "$(command -v dialog)" ]; then
      which brew >/dev/null
      brew install dialog || (echo "Brew não encontrado, saindo" && exit 1)
    fi
  else
    echo "Sistema não foi detectado, saindo.."

    exit 1
  fi
}

case "$1" in
  -run )
    help

    echo -n "Inicializando..."; spin; echo

    # Inicio das chamadas das funções
    echo -n "Deseja continuar com a instalação? "
    read InstallReadInstallationOption

    if [ "${InstallReadInstallationOption}" != "yes" -a \
        "${InstallReadInstallationOption}" != "y" -a \
        "${InstallReadInstallationOption}" != "sim" -a \
        "${InstallReadInstallationOption}" != "s" ]; then
      echo "Saindo do instalador..."

      exit 1
    fi
    (
      cd ${InstallPathDevelopment}
      git clone ${InstallGitlabNamespaceProject}/${InstallProjectName} 2>/dev/null

      cd ${InstallProjectName} && mkdir -p ${InstallPathCredentials}
    )

    InstallSystemVerifyFiles
    InstallCreateMandatoryDirectories
  ;;

  -check )
    echo "Fazendo verificação dos arquivos de configuração necessários.."
    InstallSystemVerifyFiles
    InstallSystemDialog
  ;;
  -h | --help )
    help ;;
  *) help
esac

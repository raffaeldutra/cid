# Cores para terminal
declare _RED="$(tput setaf 1)"
declare _GREEN="$(tput setaf 2)"
declare _YELLOW=$(tput setaf 3)
declare _BLUE=$(tput setaf 4)
declare _MAGENTA=$(tput setaf 5)
declare _CYAN=$(tput setaf 6)
declare _WHYTE=$(tput setaf 7)
declare _RESET=$(tput sgr0)
declare _BOLD=$(tput bold)

# Include de todos os arquivos da CLI que foram determinados no arquivo .env.config
# Caso este arquivo não seja encontrado irá retornar um erro.
source ${HOME}/.env.config

# Funções obrigatorias que devem estar nos containers
source "${CLI_FULL_PATH}/src/docker.sh"
source "${CLI_FULL_PATH}/src/git.sh"
source "${CLI_FULL_PATH}/src/os.sh"

for ToolsToInclude in ${ENV_CONFIG_TOOLS[@]}; do
  source "${CLI_FULL_PATH}/src/${ToolsToInclude}.sh"
done

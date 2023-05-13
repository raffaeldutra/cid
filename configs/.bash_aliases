# Aliases

alias wget='wget -q --show-progress'
alias curl='curl -L --progress-bar'
alias l='ls -lah --color=always'
alias t='terraform fmt;terraform'
alias terraform='terraform fmt;terraform'
alias k='kubectl'
alias i='istioctl'
alias h='helm'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias ${CLI_ALIAS}='cli'
alias ${CLIENT_NAME}='cli'
alias env='env | sort'

export HISTSIZE=1000
export HISTFILESIZE=1000000
export HISTTIMEFORMAT='%b %d %I:%M %p '
export HISTCONTROL=ignoreboth # ignoreups:ignorespace
export HISTIGNORE="history:pwd:exit:df:ps;l:ls:ls -la:ll"

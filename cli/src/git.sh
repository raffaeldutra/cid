# @function: GitGetCurrentBranch
# @description: Retorna o nome do branch corrente
# @noargs
# @return: String
# @exitcode 0 Sucesso
function GitGetCurrentBranch() {
  if [ -d .git ]; then
    git branch 2> /dev/null | \
    sed -e "/^[^*]/d" | \
    sed -e "s/* //g"
  fi
}

# @function: GitGetLastCommitDate
# @description:
# @noargs
# @return: String
# @exitcode 0 Sucesso
function GitGetLastCommitDate() {
  git log -1 --format=%cd --date=format:'%d-%m-%Y às %H:%M:%S'
}

# @function: GitGetLastCommit
# @description:
# @noargs
# @return: String
# @exitcode 0 Sucesso
function GitGetLastCommit() {
  git rev-parse HEAD
}

# @function: GitGetLastCommitShort
# @description:
# @noargs
# @return: String
# @exitcode 0 Sucesso
function GitGetLastCommitShort() {
  git rev-parse --short HEAD
}

# @function: GitGetLastCommitAuthorName
# @description:
# @noargs
# @return: String
# @exitcode 0 Sucesso
function GitGetLastCommitAuthorName() {
  git log -1 --pretty=format:'%an'
}

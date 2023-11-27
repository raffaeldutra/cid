# @function: JokeChuckNorris
# @description: Retorna uma piada do mestre Chuck Norris
# @noargs
# @return: String
# @exitcode 0 Sucesso
function JokeChuckNorris() {
  curl -s https://api.chucknorris.io/jokes/random | jq -r '.value'
}

# @function: JokeJoke
# @description: Retorna uma piada
# @noargs
# @return: String
# @exitcode 0 Sucesso
function JokeJoke() {
  curl -s https://icanhazdadjoke.com/ | jq -r '.joke'
}

# @function: TerraformInstallCheckov
# @description: Instala Checkov para análise de código em Terraform/Cloudformation
# @noargs
# @return: void
# @exitcode 0 Sucesso
function TerraformInstallCheckov() {
  pip3 install checkov
}

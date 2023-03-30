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

# Especifica para a imagem base qual arquitetura deseja utilizar
ARG ARCH

FROM --platform="${ARCH}" ubuntu:22.04

# Todas variáveis de ambiente necessário
ENV TZ=America/Sao_Paulo
ENV LC_ALL=pt_BR.utf8
ENV LANG=pt_BR.utf8
ENV LANGUAGE=pt_BR.utf8
ENV PYTHONIOENCODING=UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes

LABEL contributors="Diego Maia"
LABEL contributors="Júlio Swytzka"
LABEL maintainer="Rafael Dutra <raffaeldutra@gmail.com>"
LABEL description="Developing environment using Docker and Docker Compose"

# https://github.com/aws/aws-cli/issues/4685#issuecomment-829600284

# Lista de pacotes para Ubuntu para quando precisar adicionar na lista abaixo:
# https://packages.ubuntu.com/
RUN apt-get update -qq --fix-missing --yes && \
  apt-get install -qq --no-install-recommends --yes \
    ca-certificates \
    gcc \
    git \
    less \
    coreutils \
    libffi-dev \
    make \
    openssh-client \
    vim \
    wget \
    unzip \
    libcurl4 \
    curl \
    jq \
    nmap \
    util-linux \
    bash-completion \
    tree \
    file \
    dnsutils \
    python3.10 \
    python3-pip \
    locales \
    locales-all \
    bc \
    mysql-client \
    python3-virtualenv \
    python3.10-venv \
    tzdata && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  ln -sf /usr/bin/python3.10 /usr/bin/python3

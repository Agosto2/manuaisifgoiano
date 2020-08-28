# Construtor de Dependências Python
#
# Imagem oficial completa do Python baseada em Debian
# -----------------------------------------------------------------------------
FROM python:2.7.18-buster as builder

# Desabilita diálogos durante a instalação dos pacotes
ENV DEBIAN_FRONTEND=noninteractive PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1

# Instala os pacotes necessários para a construção das dependências
RUN apt-get -qy update \
    && apt-get -y install --no-install-recommends \
    apt-utils=1.8.2.1 \
    dialog=1.3-20190211-1 2>&1 \
    build-essential=12.6 \
    libsasl2-dev=2.1.27+dfsg-1+deb10u1 \
    libldap2-dev=2.4.47+dfsg-3+deb10u2

COPY requirements.txt /tmp/pip-tmp/requirements.txt

# Garante que os executáveis Python e pip usados
# sejam os do nosso virtualenv
ENV PATH="/opt/venv/bin:$PATH"

# Instala as dependências do Python de base/produção
RUN virtualenv /opt/venv
RUN pip install --upgrade pip
RUN pip install --no-compile --no-cache-dir -r /tmp/pip-tmp/requirements.txt

# Construtor da Imagem Base
#
# Imagem Python oficial mais leve baseada em Debian
# -----------------------------------------------------------------------------
FROM python:2.7.18-slim-buster as base

# Desabilita diálogos durante a instalação dos pacotes
ENV DEBIAN_FRONTEND=noninteractive PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1

RUN echo "tzdata tzdata/Areas select America" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/America select Sao_Paulo" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt \
    && rm /etc/timezone \
    && rm /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# Configura o apt e instala pacotes
RUN apt-get -qy update \
    && apt-get -y install --no-install-recommends \
    apt-utils=1.8.2.1 \
    dialog=1.3-20190211-1 2>&1 \
    gettext=0.19.8.1-9 \
    libsasl2-2=2.1.27+dfsg-1+deb10u1 \
    libldap-2.4-2=2.4.47+dfsg-3+deb10u2 \
    postgresql-client=11+200+deb10u3 \
    locales=2.28-10 \
    locales-all=2.28-10 \
    # Remove arquivos temporários
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Atualiza os locales
ENV LANG pt_BR.UTF-8

WORKDIR /workspace

# Construtor da Imagem de Desenvolvimento
#
# Imagem Python oficial mais leve baseada em Debian
# -----------------------------------------------------------------------------
FROM base as development

# Configura o apt e instala pacotes
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    && apt-get -qy update \
    #
    # Verifica se o git, ferramentas de processo e lsb-release estão instalados
    && apt-get -y install --no-install-recommends \
    git=1:2.20.1-2+deb10u3 \
    iproute2=4.20.0-2 \
    procps=2:3.3.15-2 \
    lsb-release=10.2019051400 \
    openssh-client=1:7.9p1-10+deb10u2 \
    # Remove arquivos temporários
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Garante que os executáveis Python e pip usados
# na imagem sejam os do nosso virtualenv
ENV PATH="/opt/venv/bin:$PATH"

# Copia o ambiente Python
COPY --from=builder /opt/venv /opt/venv

# Volta ao diálogo para qualquer uso ad-hoc do apt-get
ENV DEBIAN_FRONTEND=dialog

# Construtor da Imagem de Testes
#
# Imagem Python oficial mais leve baseada em Debian
# -----------------------------------------------------------------------------
FROM development as testing

COPY . /workspace

# Construtor da Imagem de Produção
#
# Imagem Python oficial mais leve baseada em Debian
# -----------------------------------------------------------------------------
FROM base as production

# Garante que os executáveis Python e pip usados
# na imagem sejam os do nosso virtualenv
ENV PATH="/opt/venv/bin:$PATH"

# Copia o ambiente Python
COPY --from=builder /opt/venv /opt/venv

COPY . /workspace

# Compila os arquivos de tradução para português
RUN python manage.py compilemessages

# Volta ao diálogo para qualquer uso ad-hoc do apt-get
ENV DEBIAN_FRONTEND=dialog

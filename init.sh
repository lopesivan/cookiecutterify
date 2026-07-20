#!/usr/bin/env bash
set -e # Encerra em caso de erro
set -u # Trata variáveis não definidas como erro
set -o pipefail

GITHUB_USER=$1
REPO_NAME=$2
PATCH=$3
PACKAGE=$(yq -r ".variables.package_name.value" cookie.yml)

# ${REPO_NAME}
# ============
#

# Remove uma cópia anterior, se existir
test -d ${REPO_NAME} && rm -rf ${REPO_NAME}

#clona repositório
git clone https://github.com/${GITHUB_USER}/${REPO_NAME}
pushd ${REPO_NAME}
echo aplica o patch
echo git am ../${PATCH}
git am ../${PATCH}
popd >/dev/null

# ${REPO_NAME}.COPY
# =================
#

# Remove uma cópia anterior, se existir
test -d ${REPO_NAME}.COPY && rm -rf ${REPO_NAME}.COPY

# Faz uma nova cópia
cp -r ${REPO_NAME} ${REPO_NAME}.COPY

# Entra no diretório
pushd ${REPO_NAME}.COPY >/dev/null

# remove arquivos de configuracao
for path in \
    ./.project \
    ./app/.project \
    ./.settings \
    ./app/.settings \
    ./app/.classpath \
    ./kls_database.db \
    ./.idea \
    ./.git \
    ./.google; do
    [[ -e "$path" ]] && rm -rf -- "$path" && echo "[rm] $path"
done

# ----------------------------------------------------------------------------
#
# ... área para realizar alterações ...
#
# ----------------------------------------------------------------------------

# cria um novo repositório e faz commit
git init
git add .
git commit -m "first commit"
git clean -dfx

tree .
popd >/dev/null

exit 0

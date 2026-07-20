#!/usr/bin/env bash
set -e # Encerra em caso de erro
set -u # Trata variáveis não definidas como erro
set -o pipefail

GITHUB_USER=$1
REPO_NAME=$2
PATCH=$3

# Remove uma cópia anterior, se existir
test -d ${REPO_NAME} && rm -rf ${REPO_NAME}

USE_GIT_CLONE=true
if $USE_GIT_CLONE; then
    git clone "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

    pushd "${REPO_NAME}" >/dev/null
    git am "../${PATCH}"
    popd >/dev/null
else
    tar xvzf "${REPO_NAME}.tar.gz"
fi

# ${REPO_NAME}.COPY
# =================

# Remove uma cópia anterior, se existir
test -d ${REPO_NAME}.COPY && rm -rf ${REPO_NAME}.COPY

# Faz uma nova cópia
cp -r ${REPO_NAME} ${REPO_NAME}.COPY

# ----------------------------------------------------------------------------
# 1) primeira açao: cópia e executa os comandos git
pushd ${REPO_NAME}.COPY >/dev/null

# Remove a linha 'local.properties' do .gitignore
sed '/local.properties/ d' -i .gitignore

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

git init
git add .
git commit -m "first commit"
git clean -dfx
popd >/dev/null

# ----------------------------------------------------------------------------
# 2) Segunda açao: package path -> __PACKAGE__
PACKAGE=$(yq -r ".variables.package_name.value" cookie.yml)
pushd ${REPO_NAME}.COPY >/dev/null
root_dir="${PWD}"
pattern="${PACKAGE//./\/}"

# Process substitution: o loop é executado no shell atual, não em um subshell
while IFS= read -r line; do
    echo "=$line="
    dir="${line%$pattern}" # ex: ./app/src/main/kotlin/
    top="${pattern%%/*}"   # ex: com

    pushd "$dir" >/dev/null
    mv -- "$pattern" __PACKAGE__
    rm -rf -- "$top"
    # echo "mv $pattern -> __PACKAGE__"
    # echo "rm -rf $top"
    popd >/dev/null

    #done < <(find . -depth -type d | grep "$pattern")
done < <(find . -type d | grep "$pattern$")

tree .
popd >/dev/null

exit 0

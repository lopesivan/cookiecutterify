#!/usr/bin/env bash
set -e # Encerra em caso de erro
set -u # Trata variáveis não definidas como erro
set -o pipefail

PACKAGE=$(yq -r ".variables.package_name.value" cookie.yml)

# Remove uma cópia anterior, se existir
test -d MyApplication && rm -rf MyApplication

# Copia o projeto original para o diretório atual
#cp -r /workspace/AndroidStudioProjects/MyApplication .

# Extrai o arquivo.tar.gz.
tar xvzf MyApplication.tar.gz

# Remove uma cópia anterior, se existir
test -d MyApplication.COPY && rm -rf MyApplication.COPY

# Faz uma nova cópia
cp -r MyApplication MyApplication.COPY

# Remove a linha 'local.properties' do .gitignore
sed '/local.properties/ d' -i MyApplication.COPY/.gitignore

# Entra no diretório da cópia e executa os comandos git
pushd MyApplication.COPY >/dev/null
rm -rf .idea
git init
git add .
git commit -m "first commit"
git clean -dfx

root_dir="${PWD}"
pattern="${PACKAGE//./\/}"

# Process substitution: o loop é executado no shell atual, não em um subshell
while IFS= read -r line; do
    echo "=$line="
    dir="${line%$pattern}" # Extrai o diretório pai

    pushd "$dir" >/dev/null
    mv "$pattern" __PACKAGE__
    rm -rf "${pattern%%/*}"

    popd >/dev/null
done < <(find . -type d | grep "$pattern")

tree .
popd >/dev/null

exit 0

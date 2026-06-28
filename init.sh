#!/usr/bin/env bash
set -e # Encerra em caso de erro
set -u # Trata variáveis não definidas como erro
set -o pipefail

PACKAGE=$(yq -r ".variables.package_name.value" cookie.yml)

# Copia o projeto original para o diretório atual
#cp -r /workspace/AndroidStudioProjects/HelloAndroid .

# Remove uma cópia anterior, se existir
test -d HelloAndroid && rm -rf HelloAndroid

#clona repositório
git clone https://github.com/lopesivan/HelloAndroid
pushd HelloAndroid
echo aplica o patch
git am ../HelloAndroid-custom-5cc26bd-20260628.patch
popd >/dev/null

# Remove uma cópia anterior, se existir
test -d HelloAndroid.COPY && rm -rf HelloAndroid.COPY

# Faz uma nova cópia
cp -r HelloAndroid HelloAndroid.COPY

# Remove a linha 'local.properties' do .gitignore
sed '/local.properties/ d' -i HelloAndroid.COPY/.gitignore

# Entra no diretório da cópia e executa os comandos git
pushd HelloAndroid.COPY >/dev/null
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

#PACKAGE=com.example.android.helloandroid
pattern="${PACKAGE//./\/}"

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
#                                       ^
#                         ancora no fim: ignora ui/theme e ui
tree .
popd >/dev/null

exit 0

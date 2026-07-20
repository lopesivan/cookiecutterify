#!/usr/bin/env bash
set -e # Encerra em caso de erro
set -u # Trata variáveis não definidas como erro
set -o pipefail

name=${1-template-mono}
sed "s/HelloAndroid/$name/g" -i \
    ./Makefile.test \
    ./cookie.yml \
    ./init.sh \
    ./scan.sh \
    sandbox/Makefile \
    .gitignore

PLATAFORM=
TEMPLATE_MODEL=
LANGUAGE=

exit 0

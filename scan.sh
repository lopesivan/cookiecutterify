#!/usr/bin/env bash
set -euo pipefail

config="${CONFIG:-cookie.yml}"
src="${SRC:-MyApplication.COPY}"
dst="${DST:-MyApplication.cookiecutter}"
out="${OUT:-cookiecutter-android-native_cpp-java}"

test -d $dst && rm -rf $dst
test -d $out && rm -rf $out

declare -ga VAR_KEYS=()
declare -gA VAR_MAP=()

load_variables() {
    while IFS=$'\t' read -r key value; do
        [[ "$value" == "null" || -z "$value" ]] && continue
        VAR_KEYS+=("$key")
        VAR_MAP["$key"]="$value"
    done < <(yq -r '.variables | to_entries[] | [.key, .value.value] | @tsv' "$config")
}

ignore_path() {
    local path="$1"
    [[ "$path" == *"/.git/"* ]] && return 0
    [[ "$path" == *"/build/"* ]] && return 0
    [[ "$path" == *"/.gradle/"* ]] && return 0
    [[ "$path" == *"/.idea/"* ]] && return 0
    return 1
}

is_text_file() {
    grep -Iq . "$1"
}

make_cookiecutter_json() {
    echo "[fase] gerando cookiecutter.json"
    yq -o=json '
        .variables
        | with_entries(.value = .value.value)
    ' "$config" >"$dst/cookiecutter.json"
    echo "[ok] gerado: $dst/cookiecutter.json"
}

replace_file_contents() {
    echo "[fase] substituindo conteúdo dos arquivos"

    find "$dst" -mindepth 1 -type f |
        while IFS= read -r file; do
            ignore_path "$file" && continue
            is_text_file "$file" || continue

            for key in "${VAR_KEYS[@]}"; do
                value="${VAR_MAP[$key]}"
                placeholder="{{ cookiecutter.${key} }}"

                printf 'DEBUG key=%q value=%q placeholder=%q\n' "$key" "$value" "$placeholder"

                if grep -qF -- "$value" "$file"; then
                    echo "[edit] $file :: $value -> $placeholder"
                    VALUE="$value" PLACEHOLDER="$placeholder" \
                        perl -0pi -e 's/\Q$ENV{VALUE}\E/$ENV{PLACEHOLDER}/g' "$file"
                fi
            done
        done
}

rename_files() {
    echo "[fase] renomeando arquivos"

    find "$dst" -mindepth 1 -type f |
        while IFS= read -r file; do
            ignore_path "$file" && continue

            newfile="$file"
            for key in "${!VAR_MAP[@]}"; do
                value="${VAR_MAP[$key]}"
                placeholder="{{ cookiecutter.${key} }}"
                newfile="${newfile//$value/$placeholder}"
            done

            if [[ "$newfile" != "$file" ]]; then
                echo "[mv file] $file -> $newfile"
                mkdir -p -- "$(dirname "$newfile")"
                mv -- "$file" "$newfile"
            fi
        done
}

main() {
    if [[ ! -f "$config" ]]; then
        echo "erro: arquivo não encontrado: $config" >&2
        exit 1
    fi

    if [[ ! -d "$src" ]]; then
        echo "erro: projeto não encontrado: $src" >&2
        exit 1
    fi

    if [[ -e "$dst" ]]; then
        echo "erro: destino já existe: $dst" >&2
        exit 1
    fi

    load_variables

    echo "[fase] copiando projeto"
    cp -a -- "$src" "$dst"

    replace_file_contents

    cp Makefile.orig MyApplication.cookiecutter/Makefile
    cp -r mk MyApplication.cookiecutter/

    cp ui-info.py.orig MyApplication.cookiecutter/ui-info.py

    cp processa-taps.sh.orig MyApplication.cookiecutter/processa-taps.sh
    cp tap-select.py.orig MyApplication.cookiecutter/tap-select.py
    chmod +x MyApplication.cookiecutter/tap-select.py \
        MyApplication.cookiecutter/processa-taps.sh

    rename_files

    mkdir ${out}
    mv \{\{\ cookiecutter.__app_name_without_space\ \}\}.cookiecutter/ ${out}/\{\{\ cookiecutter.__app_name_without_space\ \}\}
    cp cookiecutter.json.orig ${out}/cookiecutter.json

    #rename_dirs
    #make_cookiecutter_json
    cat README.md.conf | sed \
        -e 's/__PLATAFORM__/android/g' \
        -e 's/__TEMPLATE_MODEL__/native_cpp/g' \
        -e 's/__LANGUAGE__/java/g' >${out}/README.md

    cp Makefile.test ${out}/Makefile

    echo "[ok] template criado em: $dst"
}

main "$@"

exit 0

#!/usr/bin/env bash
set -euo pipefail

# ./scan.sh $(REPONAME) $(CONFIG) $(SRC) $(DST) $(OUT)
REPO_NAME=$1
config=$2
src=$3
dst=$4
out=$5

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

    rm -rf "$dst"
    echo "[fase] copiando projeto"
    echo cp -a -- "$src" "$dst"
    cp -a -- "$src" "$dst"

    replace_file_contents

    # DEST="${REPO_NAME}.cookiecutter"
    #
    # pushd "${DEST}" >/dev/null
    #
    # # Arquivos de build.
    # f=Makefile.orig
    # cp ../$f ${f%.orig}
    # # copia diretório
    # cp -r ../mk .
    #
    # # Ferramentas.
    # for f in \
    #     ui-info.py.orig \
    #     processa-taps.sh.orig \
    #     tap-select.py.orig; do
    #
    #     cp "../$f" "${f%.orig}"
    # done
    #
    # # Torna os scripts executáveis.
    # chmod +x \
    #     processa-taps.sh \
    #     tap-select.py
    #
    # popd >/dev/null

    rename_files

    mkdir ${out}
    mv '{{ cookiecutter.__app_name_without_space_lower }}.cookiecutter' ${out}/

    cp cookiecutter.json.orig ${out}/cookiecutter.json

    cp Makefile.test ${out}/Makefile

    f=Makefile.test
    cp $f ${out}/${f%.test}

    echo "[ok] template criado em: $dst"
}

main "$@"

exit 0

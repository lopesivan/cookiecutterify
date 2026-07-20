#!/usr/bin/env bash
set -euo pipefail

PROJECT="${1:-.}"

gradle() {
    grep -RhoP "$1" "$PROJECT" 2>/dev/null | head -n1 || true
}

manifest() {
    grep -RhoP "$1" "$PROJECT" 2>/dev/null | head -n1 || true
}

application_name=$(
    manifest '(?<=android:label=")[^"]+' ||
        basename "$PROJECT"
)

application_id=$(gradle '(?<=applicationId = ")[^"]+')
[[ -z "$application_id" ]] &&
    application_id=$(gradle '(?<=applicationId ")[^"]+')

namespace=$(gradle '(?<=namespace = ")[^"]+')
[[ -z "$namespace" ]] &&
    namespace="$application_id"

compile_sdk=$(gradle '(?<=compileSdk = )[0-9]+')
[[ -z "$compile_sdk" ]] &&
    compile_sdk=$(gradle '(?<=compileSdk )[0-9]+')

min_sdk=$(gradle '(?<=minSdk = )[0-9]+')
[[ -z "$min_sdk" ]] &&
    min_sdk=$(gradle '(?<=minSdk )[0-9]+')

target_sdk=$(gradle '(?<=targetSdk = )[0-9]+')
[[ -z "$target_sdk" ]] &&
    target_sdk=$(gradle '(?<=targetSdk )[0-9]+')

cat <<EOF
variables:

  app_name:
    description: Application name
    value: "$application_name"

  application_id:
    description: Application ID
    value: "$application_id"

  namespace:
    description: Namespace
    value: "$namespace"

  compile_sdk:
    description: Compile SDK
    value: $compile_sdk

  min_sdk:
    description: Min SDK
    value: $min_sdk

  target_sdk:
    description: Target SDK
    value: $target_sdk

EOF

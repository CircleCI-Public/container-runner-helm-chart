#!/usr/bin/env bash
set -euo pipefail

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_version="Print version"
version() {
    grep version Chart.yaml | sed -nE 's/.*"(.*)".*/\1/p'
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
package_helm="Check that the version has been updated in the Helm chart"
check-version-bump() {
    previous_commit=$( [ "$(git rev-parse --abbrev-ref HEAD)" == "main" ] && echo 'HEAD^' || echo 'main' )

    if ! git diff --quiet "${previous_commit}" HEAD -- ./templates ./values.yaml \
        && [ "$(version)" == "$(git show "${previous_commit}:Chart.yaml" | grep version | sed -nE 's/.*"(.*)".*/\1/p')" ]; then

        echo "Error: the templates or values file have been modified, but the chart version hasn't been updated to reflect that"
        exit 1
    fi
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_package="Package the Helm chart"
package() {
    mkdir -p target
    cd target || return

    local arg="${1:-}"
    if [ ! -z "${arg}" ]; then
        shift
    fi

    echo 'Package Helm chart'
    case ${arg} in
    "sign")
        echo 'Sign Helm chart'
        # shellcheck disable=SC2086
        helm package --sign --key "${KEY:-<eng-on-prem@circleci.com>}" --keyring ${KEYRING:-~/.gnupg/secring.gpg} .. "$@"
        echo 'Verify Helm chart signature'
        helm verify ./container-agent-*.tgz
        ;;
    *)
        helm package ..
        ;;
    esac

    echo 'Check contents of Helm package'
    ls .
    tar -tvf ./container-agent-*.tgz
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_publish="Push the Helm chart to Packagecloud"
publish() {
    if ! [ -x "$(command -v package_cloud)" ]; then
        echo 'The packagecloud CLI is required. See: https://packagecloud.io/l/cli'
        exit 1
    fi

    package_cloud push circleci/container-agent/helm/v1 ./target/container-agent-*.tgz
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_unit_tests="Run helm unittest"
unit-tests() {
    if ! [ -x "$(command -v helm)" ]; then
        echo 'Helm is required. See: https://helm.sh/docs/intro/install/'
        exit 1
    fi

    if ! helm plugin list | grep unittest >/dev/null; then
        echo 'Installing helm unittest'
        helm plugin install https://github.com/helm-unittest/helm-unittest.git
    fi

    helm unittest -f 'tests/*.yaml' . "$@"
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_generate_readme="Generate docs for the Helm chart"
generate-readme() {
    if ! [ -x "$(command -v helm-docs)" ]; then
        go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
    fi

    helm-docs -t ./templates/README.md.gotmpl . "$@"
}

help-text-intro() {
    echo "
DO

A set of simple repetitive tasks that adds minimally
to standard tools used to build and test the service.
(e.g. go and docker)
"
}

### START FRAMEWORK ###
# Do Version 0.0.4
# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_self_update="Update the framework from a file.

Usage: $0 self-update FILENAME
"
self-update() {
    local source selfpath pattern
    source="$1"
    selfpath="${BASH_SOURCE[0]}"
    cp "$selfpath" "$selfpath.bak"
    pattern='/### START FRAMEWORK/,/END FRAMEWORK ###$/'
    (
        sed "${pattern}d" "$selfpath"
        sed -n "${pattern}p" "$source"
    ) \
        >"$selfpath.new"
    mv "$selfpath.new" "$selfpath"
    chmod --reference="$selfpath.bak" "$selfpath"
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_completion="Print shell completion function for this script.

Usage: $0 completion SHELL"
completion() {
    local shell
    shell="${1-}"

    if [ -z "$shell" ]; then
        echo "Usage: $0 completion SHELL" 1>&2
        exit 1
    fi

    case "$shell" in
    bash)
        (
            echo
            echo '_dotslashdo_completions() { '
            # shellcheck disable=SC2016
            echo '  COMPREPLY=($(compgen -W "$('"$0"' list)" "${COMP_WORDS[1]}"))'
            echo '}'
            echo 'complete -F _dotslashdo_completions '"$0"
        )
        ;;
    zsh)
        cat <<EOF
_dotslashdo_completions() {
  local -a subcmds
  subcmds=()
  DO_HELP_SKIP_INTRO=1 $0 help | while read line; do
EOF
        cat <<'EOF'
    cmd=$(cut -f1  <<< $line)
    cmd=$(awk '{$1=$1};1' <<< $cmd)

    desc=$(cut -f2- <<< $line)
    desc=$(awk '{$1=$1};1' <<< $desc)

    subcmds+=("$cmd:$desc")
  done
  _describe 'do' subcmds
}

compdef _dotslashdo_completions do
EOF
        ;;
    fish)
        cat <<EOF
complete -e -c do
complete -f -c do
for line in (string split \n (DO_HELP_SKIP_INTRO=1 $0 help))
EOF
        cat <<'EOF'
  set cmd (string split \t $line)
  complete -c do  -a $cmd[1] -d $cmd[2]
end
EOF
        ;;
    esac
}

list() {
    declare -F | awk '{print $3}'
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_help="Print help text, or detailed help for a task."
help() {
    local item
    item="${1-}"
    if [ -n "${item}" ]; then
        local help_name
        help_name="help_${item//-/_}"
        echo "${!help_name-}"
        return
    fi

    if [ -z "${DO_HELP_SKIP_INTRO-}" ]; then
        type -t help-text-intro >/dev/null && help-text-intro
    fi
    for item in $(list); do
        local help_name text
        help_name="help_${item//-/_}"
        text="${!help_name-}"
        [ -n "$text" ] && printf "%-30s\t%s\n" "$item" "$(echo "$text" | head -1)"
    done
}

case "${1-}" in
list) list ;;
"" | "help") help "${2-}" ;;
*)
    if ! declare -F "${1}" >/dev/null; then
        printf "Unknown target: %s\n\n" "${1}"
        help
        exit 1
    else
        "$@"
    fi
    ;;
esac
### END FRAMEWORK ###

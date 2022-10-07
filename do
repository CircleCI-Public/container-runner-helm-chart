#!/usr/bin/env bash
set -eu -o pipefail

_version=1.0.${CIRCLE_BUILD_NUM-0}-$(git rev-parse --short HEAD 2>/dev/null || echo latest)

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_version="Print version"
version() {
    echo "$_version"
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_preprocess_helm="Used by CI to preprocess the Helm chart with the semantic version"
preprocess-helm() {
    set -x

    if [[ -f ./target/version.txt ]]; then
        ver=$(<./target/version.txt)
    else
        ver=$(version)
    fi

    # Remove the git hash from the version to generate a release SemVer
    # Note that the MINOR version is the build number
    semver=$(echo "${ver}" | cut -f1 -d"-")

    # Below will preprocess the Helm chart files with substitutions.
    # <<semantic_version>> will be replaced with the SemVer,
    # and <<image_tag>> will be replaced with the image tag
    sed -i "s/<<semantic_version>>.*/\"${semver}\"/g" ./*.yaml
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_package_helm="Package and upload the Helm chart to S3"
package-helm() {
    set -x

    publish=${1:?'publish required: true or false'}

    [[ -z ${S3_HELM_BUCKET+z} ]] && echo 'S3_HELM_BUCKET required' && exit 1

    mkdir helm-package
    cd helm-package

    echo 'Package Helm chart and generate index file'
    helm package ..
    helm repo --url="https://${S3_HELM_BUCKET}.s3.amazonaws.com/charts/container-agent/" index .

    echo 'Check contents of Helm package and index file'
    ls .
    tar -tvf ./container-agent-*.tgz
    cat ./index.yaml

    if [ "${publish}" == true ]; then
        aws --profile cci s3 cp ./index.yaml "s3://${S3_HELM_BUCKET}/charts/"
        aws --profile cci s3 cp ./container-agent-*.tgz "s3://${S3_HELM_BUCKET}/charts/container-agent/"
    else
        echo 'Not publishing to S3'
    fi
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
helm_package_cloud_helm="Package and upload the Helm chart to package cloud"
package-cloud-helm() {
    set -x

    publish=${1:?'publish required: true or false'}

    mkdir helm-package
    cd helm-package

    echo 'Package Helm chart'
    helm package ..

    echo 'Check contents of Helm package'
    ls .
    tar -tvf ./container-agent-*.tgz

    if [ "${publish}" == true ]; then
        package_cloud push circleci/container-agent/helm/v1 ./container-agent-*.tgz
    else
        echo 'Not publishing to package cloud'
    fi
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_install_helm="Installs helm for ubuntu in CI/CD"
install-helm() {
  set -x

  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm
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

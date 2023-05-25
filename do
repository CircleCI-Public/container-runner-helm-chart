#!/usr/bin/env bash
set -eu -o pipefail

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_version="Print version"
version() {
    grep version Chart.yaml | sed -nE 's/.*"(.*)".*/\1/p'
}

check-version-bump() {
    branch=${1:?'git branch required'}

    if [ "${branch}" == "main" ]; then
        prev=HEAD^
    else
        prev=main
    fi

    if [ "$(git diff ${prev} HEAD ./templates)" != "" ] || [ "$(git diff ${prev} HEAD values.yaml)" != "" ]; then
        if [ "$(./do version)" == "$(git show HEAD^:Chart.yaml | grep version | sed -nE 's/.*"(.*)".*/\1/p')" ]; then
            exit 1
        fi
    fi
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_provision_test='Used in CI to test provision container-agent on an EKS cluster'
provision-test() {
    set -x

    echo 'Add the container agent helm chart repo'
    helm repo add container-agent https://packagecloud.io/circleci/container-agent/helm
    helm repo update

    echo 'Connect to the "container-agent" Cluster'
    aws eks update-kubeconfig --name container-agent

    echo 'Dry run the Helm chart'
    helm upgrade --install --dry-run container-agent container-agent/container-agent \
        --set "agent.name=dry-run" \
        --set "agent.image.tag=kubernetes-edge" \
        --set "agent.nodeSelector.kubernetes\.io/arch=amd64" \
        --set "agent.rbac.role.name=TestRole" \
        --set "agent.rbac.role.binding=TestRole" \
        --set "agent.pullSecrets[0].name=regcred" \
        --set "agent.image.repository=circleci/runner-agent" \
        --set "agent.terminationGracePeriodSeconds=60" \
        --set "agent.nodeSelector.kubernetes\.io/arch=arm64" \
        --set "rbac.clusterRoleBinding.name=TestClusterRole" \
        --set "rbac.clusterRole.name=TestClusterRole" \
        --set "logging.image.repository=circleci/logging-collector" \
        --set "logging.image.tag=edge"
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_package_helm="Package and upload the Helm chart to S3"
package-helm() {
    set -x

    publish=${1:?'publish required: true or false'}

    [[ -z ${S3_HELM_BUCKET+z} ]] && echo 'S3_HELM_BUCKET required' && exit 1

    mkdir -p helm-package
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
        cat ./index.yaml
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

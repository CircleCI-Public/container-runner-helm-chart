# Container Agent Helm Chart Changelog

# Edge
[#86](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/87) Added `KUBE_CONTAINER_AGENT_INSTANCE` as an environment variable so container agent is aware of its pod name.

[#84](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/84)
Fix the Pod Disruption Budget template so that it does not set both `minAvailable` and `maxUnavailable`

[#71](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/71) Added an option to configure the image name for the orchestrator container, enabling hosting in a private registry or an air-gapped environment on CircleCI server. See the [runner-init repository](https://github.com/circleci/runner-init) for more information.

[#68](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/68) Refactor: Move `logging` container-related resources to their own component subdirectory. This is to work towards a more organized Chart.

[#65](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/65) Make dnsConfig ndots configurable

[#62](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/62) Fix syntax issue in pdb template .

[#58](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/58) Use namespace for service account

# 101.1.2

[#66](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/66) Grant role list permissions for Pods and events. This change supports the migration to Kubernetes informers, which require listing resources on startup and during resync operations.

[#64](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/64) Start signing the Helm chart to ensure provenance: https://helm.sh/docs/topics/provenance/

[#59](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/59) Fix service container config example & update test


# 101.1.1

[#56](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/56) Fix bug with service container config loading

[#54](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/54) Load global service container config & add example usage 


# 101.1.0

- [#50](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/50) Take a list of pull secret names rather than requiring full YAML maps for agent image pull secrets
~~- [#47](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/47) [EXPERIMENTAL] Set correct env var for shared task volume~~
~~- [#44](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/44) [EXPERIMENTAL] Add toggle for shared task volume~~
- [#45](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/45) Set minimum kubeVersion in Chart.yaml

This is the Container Agent Helm Chart changelog
# 101.0.21
- [#42](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/42) Fix formatting bug when adding role and logging role rules

# 101.0.20

- [#41](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/41) Expose log settings for container-agent in the values file.

# 101.0.19

- [#39](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/39) fix clusterrole indentation when adding rules #39

# 101.0.18

- [#38](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/38) Add option to set the garbage collection (GC) period to tune how quickly failed Pods are removed.

# 101.0.17

- [#37](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/37) Update the values file and README for the SSH reruns [open preview](https://circleci.com/docs/container-runner-installation/#enable-rerun-job-with-ssh).

# 101.0.16

- [#36](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/36) Add field to set arbitrary environment variables for container-agent

# 101.0.15

- [#34](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/34) [PRERELEASE] Add an option to specify an existing GatewayClass for SSH reruns

# 101.0.14

- [#35](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/35) [PRERELEASE] Support the namespace field in ParametersReference for the SSH reruns GatewayClass

# 101.0.13

- [#33](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/33) [PRERELEASE] Add finalizer on GatewayClass to ensure proper cleanup

# 101.0.12

- [#31](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/31) Fixed PDB to reference the right variable

# 101.0.11

- [#16](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/16) [PRERELEASE] Support SSH reruns

# 101.0.10

- [#29](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/29) Added Proxy env support

# 101.0.8

- [#20](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/20) Use the current major release `3` tag instead of the rolling `edge` tag for the logging-collector image

# 101.0.7

- Update README with new parameters & add some documentation links to `values.yaml`

# 101.0.6

- Add `digest` paramater in `image` settings
- Add `forceUpdate` option

# 101.0.5

- Fix `logging-collector` RBAC permissions
- Annotate the correct service account name on the `logging-collector-token` secret

# 101.0.4

Simplify rbac implementation, avoid cluster role collision

# 101.0.3

Revert breaking change in 101.2 that required a list for roles and cluster roles
                                       
# 101.0.2

Break RBAC template into two seperate template files, cleanup whitespace

# 101.0.1

Remove command from agent pod spec to use command specified in the image Dockerfile

# 101.0.0

Update default image repository to `circleci/runner-agent`

## 100.0.1

Set custom service account even if `create` is set to `false` ([PR #5](https://github.com/CircleCI-Public/container-runner-helm-chart/pull/5))

## 100.0.0 

Initial release of helm chart

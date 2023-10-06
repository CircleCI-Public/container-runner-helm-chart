# Container Runner Helm Chart

## Contributing

### Prerequisites

- Kubernetes 1.12+
- Helm 3.x

### Installing the Chart

To install the chart with the release name `container-agent`:

- Run `helm repo add container-agent https://packagecloud.io/circleci/container-agent/helm`
- Run `helm repo update`
- Run `helm install container-agent container-agent/container-agent -n circleci` to install the chart
- Update the `values.yaml` file with your resource class token in the `tokens` key under the `agent` key

This will deploy the container runner to the Kubernetes cluster as a release called `container-agent`. You can view the default values by running `helm show values circleci/container-agent` and override these using the `--values` or `--set name=value` flags on the install command below. The [Helm Chart Parameters](#helm-chart-parameters) sections list the parameters that can be configured during installation.

#### Update values.yaml

To run a job with no custom configuration, add the following configuration to the Helm chart `values.yaml`. `MY_TOKEN` is your runner resource class token. Update `namespace/my-rc` with your namespace and runner resource class.

```yaml
agent:
  resourceClasses:
    namespace/my-rc:
      token: MY_TOKEN
```

To learn more about setting up Container Runner, [read our docs](https://circleci.com/docs/container-runner/)

### Uninstalling the Chart

To uninstall the `container-agent` deployment:

```
$ helm uninstall container-agent
```

The command removes all the Kubernetes objects associated with the chart and deletes the release

### Helm Chart Parameters

The following tables list the configurable parameters of the `container-agent` helm chart. For more details about these settings please
see the comments in the `values.yaml` file

#### CircleCI Settings

| Parameter                           | Description                                                | Default                       |
|-------------------------------------|------------------------------------------------------------|-------------------------------|
| agent.runnerAPI                     | Runner API URL                                             | `https://runner.circleci.com` |
| agent.name                          | The name of this runner agent                              | `""`                          |
| agent.terminationGracePeriodSeconds | Termination grace period during shutdown                   | `18300`                       |
| agent.maxRunTime                    | Max task run time. Should be shorter than the grace period | `5h`                          |
| agent.maxConcurrentTasks            | Maximum number of tasks claimed/run concurrently           | `20`                          |
| agent.kubeGCEnabled                 | Option to enabled/disable garbage collection               | `true`                        |
| agent.kubeGCThreshold               | Length of time pods can run before deleted by GC           | `5h5m`                        |
| agent.autodetectPatform             | Enable the platform autodetection feature                  | `true`                        |
| agent.customSecret                  | Name of the optional custom token secret                   | `""`                          |
| agent.resourceClasses               | The set of resource classes the agent will claim           | `{}`                          |
| agent.constraintChecker.enable      | Enable the node constraint checker                         | `false`                       |
| agent.constraintChecker.threshold   | # failed constraint checks before claiming is disabled     | `3`                           |
| agent.constraintChecker.interval    | Constraint check interval                                  | `15m`                         |     

#### Kubernetes Object Settings

| Parameter                                   | Description                                                 | Default                      |
|---------------------------------------------|-------------------------------------------------------------|------------------------------|
| nameOverride                                | Override the chart name                                     | `""`                         |
| fullnameOverride                            | Override the full generated name                            | `""`                         |
| agent.replicaCount                          | Number of container agents to deploy                        | `1`                          |
| agent.image.registry                        | Agent image registry                                        | `""`                         |
| agent.image.repository                      | Agent image repository                                      | `circleci/runner-agent`      |
| agent.pullPolicy                            | Agent image pull policy                                     | `IfNotPresent`               |
| agent.tag                                   | Agent image tag                                             | `kubernetes-3`               |
| logging.image.registry                      | Logging agent image registry                                | `""`                         |
| logging.image.repository                    | Logging agent image repository                              | `circleci/logging-collector` |
| logging.pullPolicy                          | Logging agent image pull policy                             | `IfNotPresent`               |
| logging.tag                                 | Logging agent image tag                                     | `latest`                     |
| agent.pullSecrets                           | Secret objects container private registry credentials       | `[]`                         |
| agent.matchLabels                           | Match labels used on agent pods                             | `app: container-agent`       |
| agent.podAnnotations                        | Extra annotations addded to agent pods                      | `{}`                         |
| agent.podSecurityContext                    | Security context policies added to agent pods               | `{}`                         |
| agent.containerSecurityContext              | Security context policies add to agent containers           | `{}`                         |
| agent.resources                             | Custom resource specifications for agent pods               | `{}`                         |
| agent.nodeSelector                          | Node selector for agent pods                                | `{}`                         |
| agent.tolerations                           | Node tolerations for agent pods                             | `[]`                         |
| agent.affinity                              | Node affinity for agent pods                                | `{}`                         |
| agent.pdb.create                            | Create a PodDisruptionBudget for the agent                  | `false`                      |
| agent.pdb.minAvailable                      | Minimum available pods in the PodDisruptionBudget           | `1`                          |
| agent.pdb.maxUnavailble                     | Maximum unavailable pods in the PodDisruptionBudget         | `1`                          |
| serviceAcccount.create                      | Create a custom service account for the agent               | `true`                       |
| logging.serviceAccount.create               | Create a custom service account for the logging agent       | `true`                       |
| rbac.create                                 | Create a role & rolebinding for the service account         | `true`                       |
| logging.rbac.create                         | Create a role & rolebinding for the logging service account | `true`                       |

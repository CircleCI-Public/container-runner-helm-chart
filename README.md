# container-agent

For deploying a CircleCI Container Agent

![Version: 101.0.9](https://img.shields.io/badge/Version-101.0.9-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3](https://img.shields.io/badge/AppVersion-3-informational?style=flat-square)

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

```console
$ helm uninstall container-agent
```

The command removes all the Kubernetes objects associated with the chart and deletes the release

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agent.affinity | object | `{}` | Agent affinity and anti-affinity Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| agent.autodetectPlatform | bool | `true` | Toggle autodetection of OS and CPU architecture to request the appropriate task-agent binary in a heterogeneous cluster. If toggled on, this requires container-agent to have certain cluster-wide permissions for nodes. If toggled off, the cluster is assumed to be homogeneous and the OS and architecture of container-agent are used. |
| agent.constraintChecker.enable | bool | `false` | Enable constraint checking (This requires at least List Node permissions) |
| agent.constraintChecker.interval | string | `"15m"` | Check interval |
| agent.constraintChecker.threshold | int | `3` | Number of failed checks before disabling task claim |
| agent.containerSecurityContext | object | `{}` | Security Context policies for agent containers |
| agent.customSecret | string | `""` | Name of the user provided secret containing resource class tokens. You can mix tokens from this secret and in the secret created from tokens specified in the resourceClasses section below Ref: https://circleci.com/docs/container-runner/#custom-secret  The tokens should be specified as secret key-value pairs of the form ResourceClass: Token The resource class name needs to match the names configured below exactly to match tokens to the correct configuration As Kubernetes does not allow / in secret keys, a period (.) should be substituted instead |
| agent.forceUpdate | bool | `false` | Force a rolling update of the agent deployment |
| agent.image | object | `{"digest":"","pullPolicy":"Always","registry":"","repository":"circleci/runner-agent","tag":"kubernetes-3"}` | Agent image settings. NOTE: Setting an image digest will take precedence over the image tag |
| agent.kubeGCEnabled | bool | `true` | Enable garbage collection of dangling Kubernetes objects managed by container agent |
| agent.kubeGCThreshold | string | `"5h5m"` | The age of a Kubernetes object managed by container agent before the garbage collection deletes it |
| agent.livenessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/live","port":7623,"scheme":"HTTP"},"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness and readiness probe values Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes |
| agent.matchLabels.app | string | `"container-agent"` |  |
| agent.maxConcurrentTasks | int | `20` | Maximum number of tasks that can be run concurrently. IMPORTANT: This concurrency is independent of, and may be limited by, the Runner concurrency of your plan. Configure this value at your own risk based on the resources allocated to your cluster. |
| agent.maxRunTime | string | `"5h"` |  |
| agent.name | string | `""` | A (preferably) unique name assigned to this particular container-agent instance. This name will appear in your runners inventory page in the CircleCI UI. If left unspecified, the name will default to the name of the deployment. |
| agent.nodeSelector | object | `{}` | Node labels for agent pod assignment Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| agent.pdb | object | `{"create":false,"maxUnavailable":1,"minAvailable":1}` | Pod disruption budget settings |
| agent.podAnnotations | object | `{}` | Annotations to be added to agent pods |
| agent.podSecurityContext | object | `{}` | Security Context policies for agent pods |
| agent.pullSecrets | list | `[]` |  |
| agent.readinessProbe.failureThreshold | int | `3` |  |
| agent.readinessProbe.httpGet.path | string | `"/ready"` |  |
| agent.readinessProbe.httpGet.port | int | `7623` |  |
| agent.readinessProbe.httpGet.scheme | string | `"HTTP"` |  |
| agent.readinessProbe.initialDelaySeconds | int | `10` |  |
| agent.readinessProbe.periodSeconds | int | `10` |  |
| agent.readinessProbe.successThreshold | int | `1` |  |
| agent.readinessProbe.timeoutSeconds | int | `1` |  |
| agent.replicaCount | int | `1` |  |
| agent.resourceClasses | object | `{}` | Resource class settings. The tokens specified here will be used to claim tasks & the tasks will be launched with the configured configs Ref: https://circleci.com/docs/container-runner/#resource-class-configuration-custom-pod |
| agent.resources | object | `{}` | Agent pod resource configuration Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| agent.runnerAPI | string | `"https://runner.circleci.com"` | CircleCI Runner API URL |
| agent.terminationGracePeriodSeconds | int | `18300` | Tasks are drained during the termination grace period, so this should be sufficiently long relative to the maximum run time to ensure graceful shutdown |
| agent.tolerations | list | `[]` | Node tolerations for agent scheduling to nodes with taints Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |
| logging | object | `{"image":{"registry":"","repository":"circleci/logging-collector","tag":3},"rbac":{"create":true,"role":{"name":"logging-collector","rules":[]}},"serviceAccount":{"annotations":{},"create":true,"name":"logging-collector","secret":{"name":"logging-collector-token"}}}` | Configuration values for the logging containers. These containers run alongside service containers and stream their logs to the CircleCI UI |
| logging.serviceAccount | object | `{"annotations":{},"create":true,"name":"logging-collector","secret":{"name":"logging-collector-token"}}` | A service account with minimal permissions to collect the service container logs |
| logging.serviceAccount.secret | object | `{"name":"logging-collector-token"}` | The secret containing the service account token |
| rbac | object | `{"clusterRole":{"name":"","namespace":"","rules":[]},"create":true,"role":{"name":"","namespace":"","rules":[]}}` | Kubernetes Roles Based Access Control settings |
| serviceAccount | object | `{"annotations":{},"automountServiceAccountToken":true,"create":true,"name":""}` | Kubernetes service account settings |


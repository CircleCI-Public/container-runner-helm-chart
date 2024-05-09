# container-agent

For deploying a CircleCI Container Agent

![Version: 101.0.22](https://img.shields.io/badge/Version-101.0.22-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3](https://img.shields.io/badge/AppVersion-3-informational?style=flat-square)

## Contributing

### Prerequisites

## Requirements

Kubernetes: `>= 1.25`

Helm: 3.x

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
| agent.environment | object | `{}` | A dictionary of key-value pairs to set as environment variables in the container-agent app container. Note that this does not set environment variables in a task, which can be done via `agent.resourceClasses` or [in CircleCI](https://circleci.com/docs/set-environment-variable). |
| agent.forceUpdate | bool | `false` | Force a rolling update of the agent deployment |
| agent.gc.enabled | bool | `true` | Enable garbage collection (GC) of Kubernetes objects such as Pods or Secrets left over from CircleCI tasks. Dangling objects may occur if container runner is forcefully deleted, causing the task state-tracking to be lost. GC will only remove objects labelled with `app.kubernetes.io/managed-by=circleci-container-agent`. |
| agent.gc.interval | string | `"3m"` | Frequency of GC runs. Adjust this to balance minimal lingering K8s resources vs. system load. Infrequent runs may reduce the load but could result in excess K8s resources, while frequent runs help minimize resources but could increase system load. |
| agent.gc.threshold | string | `"5h5m"` | The age of a Kubernetes object managed by container agent before GC deletes it. This value should be slightly longer than the `agent.maxRunTime` to prevent premature removal. GC may remove some objects sooner than this threshold, such as task Pod containers that fail their liveness probe. |
| agent.image | object | `{"digest":"","pullPolicy":"Always","registry":"","repository":"circleci/runner-agent","tag":"kubernetes-3"}` | Agent image settings. NOTE: Setting an image digest will take precedence over the image tag |
| agent.livenessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/live","port":7623,"scheme":"HTTP"},"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness and readiness probe values Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes |
| agent.log.format | string | `"json"` | Set the logging format for the container-agent app. Possible values are `text`, `color`, `json`, and `none`. |
| agent.log.level | string | `"info"` | Set the logging level for the container-agent app. Possible values are `debug`, `info`, `warn`, and `error`. Note: this setting isn't to be confused with the [logging sidecar container](https://circleci.com/docs/container-runner/#logging-containers) which is configured under the top-level `logging` key. |
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
| agent.ssh.controllerName | string | `"gateway.envoyproxy.io/gatewayclass-controller"` | The name of the [Gateway controller](https://gateway-api.sigs.k8s.io/implementations/). The rerun jobs with SSH feature relies on [Gateway API](https://gateway-api.sigs.k8s.io/) and its [TCPRoute](https://gateway-api.sigs.k8s.io/guides/tcp/) resource for SSH access, which requires additional setup of a compatible Gateway controller that supports TCP routing. CircleCI currently recommends [Envoy Gateway](https://gateway.envoyproxy.io/) as a Gateway controller for this. To set it up, [read the docs](https://circleci.com/docs/container-runner-installation/#1-install-envoy-gateway-to-your-cluster). |
| agent.ssh.enabled | bool | `false` | Enable [rerunning jobs with SSH](https://circleci.com/docs/ssh-access-jobs/). For instructions on how to set up this feature, [read the docs](https://circleci.com/docs/container-runner-installation/#enable-rerun-job-with-ssh). |
| agent.ssh.existingGatewayClassName | string | `""` | Option to use an existing GatewayClass instead of creating a new one. The GatewayClass is a cluster-scoped resource defined by the infrastructure provider, which you may wish to manage externally. Note that the configuration specific to SSH routing is defined in the namespace-scoped Gateway resource. For further information, see the [Gateway API reference](https://gateway-api.sigs.k8s.io/api-types/gatewayclass/#gatewayclass), and the documentation for the Gateway controller specified by `agent.ssh.controllerName`. |
| agent.ssh.numPorts | int | `20` | Specify the total number of ports for SSH. This, along with `agent.ssh.startPort`, sets the port range. Note that the number of concurrent jobs rerun using SSH will be limited by the size of this range. |
| agent.ssh.parametersRef | object | `{}` | Specify controller-specific configuration for the GatewayClass. For details, refer to the [Gateway API reference](https://gateway-api.sigs.k8s.io/api-types/gatewayclass/#gatewayclass-parameters), and the documentation for the Gateway controller specified by `agent.ssh.controllerName`. |
| agent.ssh.startPort | int | `54782` | Define the start port for SSH. This, combined with `agent.ssh.numPorts`, is used to define a range of ports. Be aware that you may need to configure your firewall or security groups to allow this port range. |
| agent.taskVolume | object | `{"enabled":false,"selector":{},"storageClassName":""}` | Use a volume to store task related binaries to avoid copying into the task pod filesystem for every task on startup. A volume of at least 1Gi is required. The chart will create a PVC and the cluster administrator must ensure an appropriate volume provider is available (or a provisioned volume) NOTE: THIS FEATURE IS EXPERIMENTAL. NO SUPPORT IS OFFERED AT THIS TIME |
| agent.taskVolume.selector | object | `{}` | Volume selector assigned to the PVC (Optional) |
| agent.taskVolume.storageClassName | string | `""` | Storage class name assigned to the PVC (Optional) |
| agent.terminationGracePeriodSeconds | int | `18300` | Tasks are drained during the termination grace period, so this should be sufficiently long relative to the maximum run time to ensure graceful shutdown |
| agent.tolerations | list | `[]` | Node tolerations for agent scheduling to nodes with taints Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |
| logging | object | `{"image":{"registry":"","repository":"circleci/logging-collector","tag":3},"rbac":{"create":true,"role":{"name":"logging-collector","rules":[]}},"serviceAccount":{"annotations":{},"create":true,"name":"logging-collector","secret":{"name":"logging-collector-token"}}}` | Configuration values for the logging containers. These containers run alongside service containers and stream their logs to the CircleCI UI |
| logging.serviceAccount | object | `{"annotations":{},"create":true,"name":"logging-collector","secret":{"name":"logging-collector-token"}}` | A service account with minimal permissions to collect the service container logs |
| logging.serviceAccount.secret | object | `{"name":"logging-collector-token"}` | The secret containing the service account token |
| proxy | object | `{"enabled":false,"http":{"auth":{"enabled":false,"password":null,"username":null},"host":"proxy.example.com","port":3128},"https":{"auth":{"enabled":false,"password":null,"username":null},"host":"proxy.example.com","port":3128},"no_proxy":[]}` | Proxy Support for Container Agent |
| proxy.enabled | bool | `false` | If false, all proxy settings are ignored |
| proxy.http | object | `{"auth":{"enabled":false,"password":null,"username":null},"host":"proxy.example.com","port":3128}` | Proxy for HTTP requests |
| proxy.https | object | `{"auth":{"enabled":false,"password":null,"username":null},"host":"proxy.example.com","port":3128}` | Proxy for HTTPS requests |
| proxy.no_proxy | list | `[]` | List of hostnames, IP CIDR blocks exempt from proxying. Loopback and intra-service traffic is never proxied. |
| rbac | object | `{"clusterRole":{"name":"","namespace":"","rules":[]},"create":true,"role":{"name":"","namespace":"","rules":[]}}` | Kubernetes Roles Based Access Control settings |
| serviceAccount | object | `{"annotations":{},"automountServiceAccountToken":true,"create":true,"name":""}` | Kubernetes service account settings |

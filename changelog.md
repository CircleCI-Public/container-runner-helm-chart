# Container Agent Helm Chart Changelog

This is the Container Agent Helm Chart changelog

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

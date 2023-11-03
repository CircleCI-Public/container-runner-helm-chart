{{/*
Expand the name of the chart.
*/}}
{{- define "container-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "container-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "container-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "container-agent.labels" -}}
helm.sh/chart: {{ include "container-agent.chart" . }}
{{ include "container-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "container-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "container-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
RBAC names
*/}}
{{- define "container-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "container-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name}}
{{- end }}
{{- end }}

{{- define "container-agent.logging.serviceAccountName" -}}
{{- if .Values.logging.serviceAccount.create }}
{{- default (include "container-agent.fullname" .) .Values.logging.serviceAccount.name }}
{{- else }}
{{- "default"}}
{{- end }}
{{- end }}

{{- define "container-agent.tokens" -}}
{{- range $rc, $value := .Values.agent.resourceClasses -}}
{{- range $key, $value := $value -}}
{{- if eq $key "token" }}
{{ $rc | replace "/" "." }}: {{ $value | b64enc }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "container-agent.create-secret" -}}
{{- if include "container-agent.tokens" . -}}
true
{{- end }}
{{- end }}

{{- define "container-agent.token-secret" -}}
{{- if .Values.agent.customSecret }}
{{- .Values.agent.customSecret -}}
{{- else }}
{{- include "container-agent.fullname" . -}}
{{- end }}
{{- end }}

{{/* 
proxy.env defines http proxy environment variables. It expects a list 
with .Values.proxy first and additional no_proxy hosts as the         
remainder of arguments 
*/}}
{{- define "proxy.env" }}
{{- $proxySettings := index . 0 }}
{{- $httpProxyUsername := index . 1 }}
{{- $httpProxyPassword := index . 2 }}
{{- $httpsProxyUsername := index . 3 }}
{{- $httpsProxyPassword := index . 4 }}
{{- $additionalNoProxyList :=  slice . 5 }}
- name: HTTP_PROXY
  {{- with $proxySettings.http }}
  value: http://{{ if .auth.enabled }}{{ $httpProxyUsername }}:{{ $httpProxyPassword }}@{{ end }}{{ .host }}:{{ .port }}
- name: http_proxy
  value: http://{{ if .auth.enabled }}{{ $httpProxyUsername }}:{{ $httpProxyPassword }}@{{ end }}{{ .host }}:{{ .port }}
  {{- end }}
- name: HTTPS_PROXY
  {{- with $proxySettings.https }}
  value: http://{{ if .auth.enabled }}{{ $httpsProxyUsername }}:{{ $httpsProxyPassword }}@{{ end }}{{ .host }}:{{ .port }}
- name: https_proxy
  value: http://{{ if .auth.enabled }}{{ $httpsProxyUsername }}:{{ $httpsProxyPassword }}@{{ end }}{{ .host }}:{{ .port }}
  {{- end }}
- name: NO_PROXY
  {{- $noProxy := concat $proxySettings.no_proxy $additionalNoProxyList }}
  value: {{ join "," $noProxy | quote }}
- name: no_proxy
  value: {{ join "," $noProxy | quote }}
{{- end }}
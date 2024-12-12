{{- define "container-agent.logging.serviceAccountName" -}}
{{- if .Values.logging.serviceAccount.create }}
{{- default (include "container-agent.fullname" .) .Values.logging.serviceAccount.name }}
{{- else }}
{{- "default"}}
{{- end }}
{{- end }}

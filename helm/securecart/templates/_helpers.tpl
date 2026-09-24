{{/*
Resolve the frontend container image.
Prefer an immutable digest when supplied; otherwise fall back to the configured tag.
*/}}
{{- define "securecart.frontendImage" -}}
{{- if .Values.frontend.image.digest -}}
{{ printf "%s@%s" .Values.frontend.image.repository .Values.frontend.image.digest }}
{{- else -}}
{{ printf "%s:%s" .Values.frontend.image.repository .Values.frontend.image.tag }}
{{- end -}}
{{- end }}

{{/*
Resolve the backend container image.
Prefer an immutable digest when supplied; otherwise fall back to the configured tag.
*/}}
{{- define "securecart.backendImage" -}}
{{- if .Values.backend.image.digest -}}
{{ printf "%s@%s" .Values.backend.image.repository .Values.backend.image.digest }}
{{- else -}}
{{ printf "%s:%s" .Values.backend.image.repository .Values.backend.image.tag }}
{{- end -}}
{{- end }}
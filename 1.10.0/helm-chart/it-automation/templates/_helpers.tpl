{{/*
*/}}
{{- define "ita.ansible.containerName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-ansible" }}
{{- end }}


{{/*
*/}}
{{- define "ita.ansible.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-ansible" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


{{/*
*/}}
{{- define "ita.backyard.containerName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-backyard" }}
{{- end }}


{{/*
*/}}
{{- define "ita.backyard.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-backyard" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


{{/*
*/}}
{{- define "ita.mariadb.containerName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-mariadb" }}
{{- end }}


{{/*
*/}}
{{- define "ita.mariadb.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-mariadb" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


{{/*
*/}}
{{- define "ita.webapp.containerName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-webapp" }}
{{- end }}


{{/*
*/}}
{{- define "ita.webapp.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-webapp" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}

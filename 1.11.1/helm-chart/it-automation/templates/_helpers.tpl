##############################################################################
# exastro-database-pvc

{{- define "ita.pvc.database.name" -}}
{{- if .Values.ita.pvc.database.name }}
{{- printf "%v" .Values.ita.pvc.database.name }}
{{- else }}
{{- printf "%s-%s" .Release.Name "exastro-database-pvc" }}
{{- end }}
{{- end }}


{{- define "ita.pvc.database.size" -}}
{{ .Values.ita.pvc.database.size }}
{{- end }}


##############################################################################
# exastro-file-pvc

{{- define "ita.pvc.file.name" -}}
{{- if .Values.ita.pvc.file.name }}
{{- printf "%v" .Values.ita.pvc.file.name }}
{{- else }}
{{- printf "%s-%s" .Release.Name "exastro-file-pvc" }}
{{- end }}
{{- end }}


{{- define "ita.pvc.file.size" -}}
{{ .Values.ita.pvc.file.size }}
{{- end }}


##############################################################################
# it-automation-cm

{{- define "ita.cm.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-cm" }}
{{- end }}


##############################################################################
# it-automation-secret

{{- define "ita.secret.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-secret" }}
{{- end }}


##############################################################################
# it-automation-init

{{- define "ita.init.instanceName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-init" }}
{{- end }}


{{- define "ita.init.labels" -}}
app.kubernetes.io/name: it-automation-init
app.kubernetes.io/instance: {{ include "ita.init.instanceName" . }}
app.kubernetes.io/version: "{{ .Values.ita.version}}"
{{- end }}


{{- define "ita.init.job.name" -}}
{{ include "ita.init.instanceName" . }}
{{- end }}


{{- define "ita.init.container.name" -}}
{{ include "ita.init.instanceName" . }}
{{- end }}


{{- define "ita.init.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-init" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-ansible

{{- define "ita.ansible.instanceName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-ansible" }}
{{- end }}


{{- define "ita.ansible.labels" -}}
app.kubernetes.io/name: it-automation-ansible
app.kubernetes.io/instance: {{ include "ita.ansible.instanceName" . }}
app.kubernetes.io/version: "{{ .Values.ita.version}}"
{{- end }}


{{- define "ita.ansible.service.name" -}}
{{ include "ita.ansible.instanceName" . }}
{{- end }}


{{- define "ita.ansible.deploy.name" -}}
{{ include "ita.ansible.instanceName" . }}
{{- end }}


{{- define "ita.ansible.container.name" -}}
{{ include "ita.ansible.instanceName" . }}
{{- end }}


{{- define "ita.ansible.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-ansible" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-backyard

{{- define "ita.backyard.instanceName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-backyard" }}
{{- end }}


{{- define "ita.backyard.labels" -}}
app.kubernetes.io/name: it-automation-backyard
app.kubernetes.io/instance: {{ include "ita.backyard.instanceName" . }}
app.kubernetes.io/version: "{{ .Values.ita.version}}"
{{- end }}


{{- define "ita.backyard.deploy.name" -}}
{{ include "ita.backyard.instanceName" . }}
{{- end }}


{{- define "ita.backyard.container.name" -}}
{{ include "ita.backyard.instanceName" . }}
{{- end }}


{{- define "ita.backyard.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-backyard" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-mariadb

{{- define "ita.mariadb.instanceName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-mariadb" }}
{{- end }}


{{- define "ita.mariadb.labels" -}}
app.kubernetes.io/name: it-automation-mariadb
app.kubernetes.io/instance: {{ include "ita.mariadb.instanceName" . }}
app.kubernetes.io/version: "{{ .Values.ita.version}}"
{{- end }}


{{- define "ita.mariadb.service.name" -}}
{{ include "ita.mariadb.instanceName" . }}
{{- end }}


{{- define "ita.mariadb.deploy.name" -}}
{{ include "ita.mariadb.instanceName" . }}
{{- end }}


{{- define "ita.mariadb.container.name" -}}
{{ include "ita.mariadb.instanceName" . }}
{{- end }}


{{- define "ita.mariadb.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-mariadb" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-webapp

{{- define "ita.webapp.instanceName" -}}
{{- printf "%s-%s" .Release.Name "it-automation-webapp" }}
{{- end }}


{{- define "ita.webapp.labels" -}}
app.kubernetes.io/name: it-automation-webapp
app.kubernetes.io/instance: {{ include "ita.webapp.instanceName" . }}
app.kubernetes.io/version: "{{ .Values.ita.version}}"
{{- end }}


{{- define "ita.webapp.service.name" -}}
{{ include "ita.webapp.instanceName" . }}
{{- end }}


{{- define "ita.webapp.deploy.name" -}}
{{ include "ita.webapp.instanceName" . }}
{{- end }}


{{- define "ita.webapp.container.name" -}}
{{ include "ita.webapp.instanceName" . }}
{{- end }}


{{- define "ita.webapp.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-webapp" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}

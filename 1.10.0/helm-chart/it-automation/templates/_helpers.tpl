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

{{- define "ita.init.job.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-init" }}
{{- end }}


{{- define "ita.init.container.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-init" }}
{{- end }}


{{- define "ita.init.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-init" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-ansible

{{- define "ita.ansible.service.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-ansible" }}
{{- end }}


{{- define "ita.ansible.deploy.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-ansible" }}
{{- end }}


{{- define "ita.ansible.container.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-ansible" }}
{{- end }}


{{- define "ita.ansible.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-ansible" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-backyard

{{- define "ita.backyard.deploy.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-backyard" }}
{{- end }}


{{- define "ita.backyard.container.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-backyard" }}
{{- end }}


{{- define "ita.backyard.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-backyard" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-mariadb

{{- define "ita.mariadb.service.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-mariadb" }}
{{- end }}


{{- define "ita.mariadb.deploy.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-mariadb" }}
{{- end }}


{{- define "ita.mariadb.container.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-mariadb" }}
{{- end }}


{{- define "ita.mariadb.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-mariadb" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}


##############################################################################
# it-automation-webapp

{{- define "ita.webapp.labels" -}}
{{- printf "%s-%s" .Release.Name "it-automation-webapp" }}
{{- end }}


{{- define "ita.webapp.service.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-webapp" }}
{{- end }}


{{- define "ita.webapp.deploy.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-webapp" }}
{{- end }}


{{- define "ita.webapp.replicas" -}}
{{- printf "%d" .Values.ita.webapp.replicas }}
{{- end }}


{{- define "ita.webapp.container.name" -}}
{{- printf "%s-%s" .Release.Name "it-automation-webapp" }}
{{- end }}


{{- define "ita.webapp.container.image" -}}
{{- printf "%s%s:%s-%s-%s" .Values.imageRepoPrefix "it-automation-webapp" .Values.ita.version .Values.ita.language .Values.ita.distro }}
{{- end }}

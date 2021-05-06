{{/* vim: set filetype=mustache: */}}
{{/*
Define the name of the instance of the adapter on the basis of the adapter mode.
*/}}
{{- define "wphhc-adapter.name" -}}
wphhc-{{.Values.adapter.mode}}-adapter
{{- end }}

{{/*
Define the topics as BROKER_INPUT_TOPICS and BROKER_OUTPUT_TOPICS on the basis of the adapter mode.
*/}}
{{- define "wphhc-adapter.topics" -}}
{{- if eq .Values.adapter.mode "camunda" }}
- name: INPUT_TOPICS
  value: 'queuing.external.messagefrom;queuing.medicalform.bundlefhir;queuing.medicalform.extractedfields;queuing.medicalform.error;queuing.external.error'
- name: OUTPUT_TOPICS
  value: 'error:queuing.medicalform.error;mirth_channel:queuing.external.messageto;capture:queuing.medicalform.raw;extract_fhir:queuing.medicalform.flatfhir;versioning:queuing.configuration.camunda;audit:queuing.audit.camunda'
{{- else }}
{{- if eq .Values.adapter.mode "mirth" }}
- name: INPUT_TOPICS
  value: 'queuing.external.messageto'
- name: OUTPUT_TOPICS
  value: 'error:queuing.external.error;wf_message:queuing.external.messagefrom;versioning:queuing.configuration.mirth'
{{- end -}}
{{- if eq .Values.adapter.mode "aidocudroid" }}
- name: INPUT_TOPICS
  value: 'queuing.medicalform.raw'
- name: OUTPUT_TOPICS
  value: 'get_result:wf_message:queuing.medicalform.extractedfields;error:queuing.medicalform.error;get_form_registration:versioning:queuing.configuration.aidocudroid'
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define custom environment properties on the basis of the adapter mode.
*/}}
{{- define "wphhc-adapter.customEnvProperties" -}}
{{- if eq .Values.adapter.mode "camunda" }}
- name: CAMUNDA_HOST
  value: camunda-interceptor
- name: CAMUNDA_PORT
  value: "8188"
- name: CAMUNDA_PATH
  value: engine-rest/message
{{- if .Values.credentials.ft_camunda_service_user }}
- name: TMP_AUTH_CREDENTIALS
  valueFrom:
    secretKeyRef:
      name: camunda-service-credentials-secret
      key: apiauth
{{- end -}}
{{- else }}
{{- if eq .Values.adapter.mode "mirth" }}
- name: MIRTH_HOST
  value: mirth-connect-channel
- name: MIRTH_PORT
  value: "31100"
- name: MIRTH_PATH
  value: channels/
{{- end -}}
{{- if eq .Values.adapter.mode "aidocudroid" }}
- name: COMPONENT_MP_REST_URL
  value: http://aidocudroid:8981/iocrapp/api
- name: AIDOCUDROID_USERNAME
  value: eu_hc
- name: AIDOCUDROID_PASSWORD
  value: 43d69f53
- name: AIDOCUDROID_MESSAGE_NAME
  value: extractedFields
- name: ADAPTER_BASE_URL
  value: http://wphhc-aidocudroid-adapter:8089
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "wphhc-adapter.labels" -}}
  app: {{include "wphhc-adapter.name" .}}
  chart: {{ .Chart.Name }}
  instance: {{ .Release.Name }}
  com.km.wphhc.broker: allowed
{{- if .Chart.AppVersion }}
  version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

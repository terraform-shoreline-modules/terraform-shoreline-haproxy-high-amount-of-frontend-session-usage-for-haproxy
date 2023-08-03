resource "shoreline_notebook" "high_backend_session_usage_in_haproxy" {
  name       = "high_backend_session_usage_in_haproxy"
  data       = file("${path.module}/data/high_backend_session_usage_in_haproxy.json")
  depends_on = [shoreline_action.invoke_check_backend_session_usage,shoreline_action.invoke_restart_haproxy]
}

resource "shoreline_file" "check_backend_session_usage" {
  name             = "check_backend_session_usage"
  input_file       = "${path.module}/data/check_backend_session_usage.sh"
  md5              = filemd5("${path.module}/data/check_backend_session_usage.sh")
  description      = "Multiple misbehaving clients that are not releasing backend sessions after use, causing a backlog of sessions."
  destination_path = "/agent/scripts/check_backend_session_usage.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restart_haproxy" {
  name             = "restart_haproxy"
  input_file       = "${path.module}/data/restart_haproxy.sh"
  md5              = filemd5("${path.module}/data/restart_haproxy.sh")
  description      = "Check if the service is running"
  destination_path = "/agent/scripts/restart_haproxy.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_backend_session_usage" {
  name        = "invoke_check_backend_session_usage"
  description = "Multiple misbehaving clients that are not releasing backend sessions after use, causing a backlog of sessions."
  command     = "`chmod +x /agent/scripts/check_backend_session_usage.sh && /agent/scripts/check_backend_session_usage.sh`"
  params      = ["PATH_TO_HAPROXY_LOG_FILE","NAME_OF_THE_BACKEND","PATH_TO_HAPROXY_CFG"]
  file_deps   = ["check_backend_session_usage"]
  enabled     = true
  depends_on  = [shoreline_file.check_backend_session_usage]
}

resource "shoreline_action" "invoke_restart_haproxy" {
  name        = "invoke_restart_haproxy"
  description = "Check if the service is running"
  command     = "`chmod +x /agent/scripts/restart_haproxy.sh && /agent/scripts/restart_haproxy.sh`"
  params      = []
  file_deps   = ["restart_haproxy"]
  enabled     = true
  depends_on  = [shoreline_file.restart_haproxy]
}


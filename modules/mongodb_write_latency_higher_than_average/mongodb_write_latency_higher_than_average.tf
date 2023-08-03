resource "shoreline_notebook" "mongodb_write_latency_higher_than_average" {
  name       = "mongodb_write_latency_higher_than_average"
  data       = file("${path.module}/data/mongodb_write_latency_higher_than_average.json")
  depends_on = [shoreline_action.invoke_get_ip_latency,shoreline_action.invoke_mongo_long_running_queries_terminator]
}

resource "shoreline_file" "get_ip_latency" {
  name             = "get_ip_latency"
  input_file       = "${path.module}/data/get_ip_latency.sh"
  md5              = filemd5("${path.module}/data/get_ip_latency.sh")
  description      = "Check the latency of MongoDB writes"
  destination_path = "/agent/scripts/get_ip_latency.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "mongo_long_running_queries_terminator" {
  name             = "mongo_long_running_queries_terminator"
  input_file       = "${path.module}/data/mongo_long_running_queries_terminator.sh"
  md5              = filemd5("${path.module}/data/mongo_long_running_queries_terminator.sh")
  description      = "Check if there are any long-running queries or operations that are causing the high write latency, optimize or terminate them if possible."
  destination_path = "/agent/scripts/mongo_long_running_queries_terminator.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_ip_latency" {
  name        = "invoke_get_ip_latency"
  description = "Check the latency of MongoDB writes"
  command     = "`chmod +x /agent/scripts/get_ip_latency.sh && /agent/scripts/get_ip_latency.sh`"
  params      = ["MONGODB_USERNAME","MONGODB_PASSWORD","MONGODB_PORT","IP_ADDRESS","MONGODB_HOST"]
  file_deps   = ["get_ip_latency"]
  enabled     = true
  depends_on  = [shoreline_file.get_ip_latency]
}

resource "shoreline_action" "invoke_mongo_long_running_queries_terminator" {
  name        = "invoke_mongo_long_running_queries_terminator"
  description = "Check if there are any long-running queries or operations that are causing the high write latency, optimize or terminate them if possible."
  command     = "`chmod +x /agent/scripts/mongo_long_running_queries_terminator.sh && /agent/scripts/mongo_long_running_queries_terminator.sh`"
  params      = ["SERVER_ADDRESS"]
  file_deps   = ["mongo_long_running_queries_terminator"]
  enabled     = true
  depends_on  = [shoreline_file.mongo_long_running_queries_terminator]
}


variable "do_token" {
  type = string
}
variable "project_name" {
  type = string
}
variable "region" {
  type = string
}

variable "k8s_version" {
  type = string
}
variable "k8s_node_size" {
  type = string
}
variable "k8s_min_nodes" {
  type        = number
  description = "Has to be at least 1"
}
variable "k8s_max_nodes" {
  type = number
}
variable "openfaas_chart_version" {
  type = string
}

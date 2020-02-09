variable "do_token" {
  type = string
}
variable "project_name" {
  type = string
}
variable "region" {
  type = string
}

variable "k8s-version" {
  type = string
}
variable "k8s-node-size" {
  type = string
}
variable "k8s-min-nodes" {
  type        = number
  description = "Has to be at least 1"
}
variable "k8s-max-nodes" {
  type = number
}
variable "openfaas-chart-version" {
  type = string
}
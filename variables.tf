variable "rgname" {
  type        = string
  description = "RG name in Azure"
}
variable "location" {
  type        = string
  description = "Resources location in Azure"
}

variable "role_name" {
  type = string
}
variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}
variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
}
variable "acr" {
  type        = string
  description = "ACR name"
}

variable "storageaccountname" {
  type        = string
  description = "storage account name"
}

variable "adminuser" {
  type        = string
  description = "admin username"
}

variable "adminpassword" {
  type = string
}

variable "elasticpool" {
  type = string
}

variable "sqldatabase" {
  type = string
}

variable "role_definition_id" {
  type = number
}
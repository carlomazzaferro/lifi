variable "region" {
  default = "us-east-1"
}

variable "cidr_block" {
  default = "172.17.0.0/16"
}

variable "az_count" {
  default = "2"
}

variable "environment" {
  description = "env we're deploying to"
  default     = "prod"
}

variable "postgres_password" {
  type = string
}

variable "redis_password" {
  type = string
}

variable "postgres_user" {
  type    = string
  default = "lifi"
}

variable "image_tag" {
  type        = string
  description = "relayer image name"
}

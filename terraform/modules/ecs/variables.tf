variable "environment" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "ecs_security_group_id" {
    type = string
}

variable "public_subnet_1_id" {
    type = string
}

variable "public_subnet_2_id" {
    type = string
}

variable "private_subnet_1_id" {
    type = string
}

variable "private_subnet_2_id" {
    type = string
}

variable "container_name" {
    type = string
}

variable "image_name" {
    type = string
}

variable "container_port" {
    type = number
}

variable "host_port" {
    type = number
}

variable "container_env_vars_config" {
    type = string
    default = ""
}
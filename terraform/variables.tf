variable "environment" {
    type = string
    default = "php-webapp"
}   
variable "region" {
    type = string
    default = "us-east-1"
}

variable "db_username" {
    type = string
    default = "admin"
}

variable "db_password" {
    type = string
    default = "admin123"
}

variable "db_name" {
    type = string
    default = "mydb"
}

variable "container_port" {
    type = number
    default = 80
}

variable "host_port" {
    type = number
    default = 80
}

variable "key_name" {
    type = string
    default = "AWS"
}

# Your hosted zone domain name
variable "domain_name" {
    type = string
    default = "pramodpro.xyz"
}

# Your application domain name
variable "my_domain_name" {
    type = string
    default = "app.pramodpro.xyz"
}

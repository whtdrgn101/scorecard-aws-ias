variable "vpc_id" {
    type = string
}

variable "environment" {
    type = string
}

variable "database_subnet_group_name" {
    type = string
}

variable "public_subnet_cidrs" {
    type = list(string)
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "database_user" {
    type = string
}

variable "database_password" {
    type = string
}
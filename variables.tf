variable "region" {
    type = string
    description = "AWS Deployment region.."
}

variable "environment" {
    type = string
    description = "Named environment for application"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-2a", "us-east-2b"]
}

variable "database_subnet_group_name" {
    type = string
    description = "Name for database subnet group"
}

variable "api_app_count" {
    type = number
    description = "Count of containers for API"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

# SSH Key Pair Name
variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "luan_key"
}




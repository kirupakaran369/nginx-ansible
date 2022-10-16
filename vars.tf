variable "region" {
  default = "us-east-1"
}
variable "zone1" {
  default = "us-east-1a"
}

variable "zone2" {
  default = "us-east-1b"
}

variable "zone3" {
  default = "us-east-1c"
}
variable "user" {
  default = "ubuntu"
}
variable "ami" {
  type = map(any)
  default = {
    us-east-1 = "ami-052efd3df9dad4825"
    us-east-2 = "ami-00f8e2c955f7ffa9b"
  }
}
variable "vpc_cidr" {
  description = "CIDR block of the vpc"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Private Subnet"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
variable "pub_key_path" {
  default = "key_pair.pub"
}
variable "priv_key_path" {
  default = "keypair"
}
variable "my_ip" {

}

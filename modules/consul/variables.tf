variable "adminregion" {}

variable "amisize" {}

variable "min_size" {}

variable "max_size" {}

variable "vpc_cidr" {}

variable "subnetaz1" {
  type = "map"
}

variable "subnetaz2" {
  type = "map"
}

variable "subnet_cidr1" {}

variable "subnet_cidr2" {}

variable "myip" {}

variable "key_name" {}

variable "public_key_path" {}

variable "asgname" {}

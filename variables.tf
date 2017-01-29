variable "adminregion" {}

variable "adminprofile" {}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "subnetaz1" {
  type = "map"
}

variable "subnetaz2" {
  type = "map"
}

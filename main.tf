//  Setup the core provider information.
provider "aws" {
  region  = "${var.adminregion}"
  profile = "${var.adminprofile}"
}

module "consul-cluster" {
  adminregion     = "${var.adminregion}"
  source          = "./modules/consul"
  amisize         = "t2.micro"
  min_size        = "5"
  max_size        = "5"
  vpc_cidr        = "10.0.0.0/16"
  subnetaz1       = "${var.subnetaz1}"
  subnetaz2       = "${var.subnetaz2}"
  subnet_cidr1    = "10.0.1.0/24"
  subnet_cidr2    = "10.0.2.0/24"
  myip            = "0.0.0.0/0"
  key_name        = "consul-cluster"
  public_key_path = "${var.public_key_path}"
}

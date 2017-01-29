# terraform-consul-cluster

This repo demonstrates how to create a resilient Consul cluster running on AWS, using Terraform. It is the companion project to my article '[Creating a Resilient Consul Cluster for Docker Microservice Discovery with Terraform and AWS](http://www.dwmkerr.com/creating-a-resilient-consul-cluster-for-docker-microservice-discovery-with-terraform-and-aws/)'.

## Prerequisites

Please install the following components:

1. [Docker](https://docs.docker.com/engine/installation/mac)
0. [Terraform](https://www.terraform.io/intro/getting-started/install.html) - `brew update && brew install terraform`.

You must also have an AWS account. If you don't, this cluster will run happily on the [AWS Free Tier](https://aws.amazon.com/free/) which only takes ten minutes to sign up with.

You will need to set up your AWS credentials. The preferred way is to install the AWS CLI and quickly run `aws configure`:

```
$ aws configure
AWS Access Key ID [None]: <Enter Access Key ID>
AWS Secret Access Key [None]: <Enter Secret Key>
Default region name [None]: ap-southeast-1
Default output format [None]:
```

This will keep your AWS credentials in the `$HOME/.aws/credentials` file, which Terraform can use. This and all other options are documented in the [Terraform: AWS Provider](https://www.terraform.io/docs/providers/aws/index.html) documentation.

## Creating the Cluster

Feel free to modify the module variables (in main.tf) and the variables in terraform.tfvars.
The cluster is implemented as a [Terraform Module](https://www.terraform.io/docs/modules/index.html). To launch, just run:

```bash
# Create the module.
terraform get

# See what we will create, or do a dry run! If there are issues
terraform plan

# Create the cluster!
terraform apply
```

By default this will use your default AWS CLI profile and associated region, feel free to modify this in tfars.

```
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

...

consul-dns = consul-lb-734949600.ap-southeast-1.elb.amazonaws.com
```

Navigate to port 8500 at address provided (e.g. http://consul-lb-734949600.ap-southeast-1.elb.amazonaws.com:8500) and you will see the Consul interface.

## Destroying the Cluster

Bring everything down with:

```
terraform destroy
```

## Project Structure

The module has the following structure:

```
variables.tf         # The basic terraform variables. Used in later files.
01-vpc.tf           # Network configuration. Defines the VPC, subnets, access etc.
main.tf    # Cluster configuration. Defines the Auto-scaling group, auto-scaling instance config etc.
02-consul-node-role.tf  # Defines policies and a role for cluster nodes.
outputs.tf           # Useful data we capture when creating infrastructure.
files/consul-node.sh # Setup script for the cluster nodes.
example-service/     # A goofy example microservice used to test the project.
```

The template renderings fixed:

- userdata -  https://github.com/arehmandev/terraform-consul-cluster/blob/master/modules/consul/files/consul-node.sh


## More info

A detailed write up of how this code works is available at:

http://www.dwmkerr.com/creating-a-resilient-consul-cluster-for-docker-microservice-discovery-with-terraform-and-aws/

## Troubleshooting

**Trying to `plan` or `apply` gives the error `No valid credential sources found for AWS Provider.`**

This means you've not set up your AWS credentials - check the [Prerequisites](#Prerequisites) section of this guide and try again, or check here: https://www.terraform.io/docs/providers/aws/index.html.

**EntityAlreadyExists: Role with name consul-instance-role already exists.**

'Already exists' errors are not uncommon with Terraform, due to the fact that some AWS resource creation can have timing or synchronisation issues. In this case, just try to create again with `terraform apply`.

## Contributors

[arehmandev](https://github.com/arehmandev) - Felt inspired by this project and ended up modularising it!

Tested 11/01/17, terraform 0.8.3

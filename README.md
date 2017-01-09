# terraform-consul-cluster

This repo demostrates how to create a resiliant Consul cluster running on AWS, using Terraform. It is the companion project to my article '[Creating a Resilient Consul Cluster for Docker Microservice Discovery with Terraform and AWS](http://www.dwmkerr.com/creating-a-resilient-consul-cluster-for-docker-microservice-discovery-with-terraform-and-aws/)'.

## Prerequisites

Please install the following components:

1. [Docker](https://docs.docker.com/engine/installation/mac)
0. [Terraform](https://www.terraform.io/intro/getting-started/install.html) - `brew update && brew install terraform`.

## Creating the Cluster

To create the cluster, register for an AWS account. You'll need to keep track of your *Secret Key* and *Access Key*. For instructions.

Now just run:

```bash
terraform apply
```

You will be asked to provide your Secret Key, Access Key and Region. When the provisioning is complete, you should see a message like:

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

The project has the following structure:

```
variables.tf         # The basic terraform variables. Used in later files.
network.tf           # Network configuration. Defines the VPC, subnets, access etc.
consul-cluster.tf    # Cluster configuration. Defines the Auto-scaling group, auto-scaling instance config etc.
consul-node-role.tf  # Defines policies and a role for cluster nodes.
outputs.tf           # Useful data we capture when creating infrastructure.
files/consul-node.sh # Setup script for the cluster nodes.
example-service/     # A goofy example microservice used to test the project.
```

## More info

A detailed write up of how this code works is available at:

http://www.dwmkerr.com/creating-a-resilient-consul-cluster-for-docker-microservice-discovery-with-terraform-and-aws/
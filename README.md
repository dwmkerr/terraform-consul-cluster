# terraform-consul-cluster

This repo demostrates how to create a resiliant [Consul](TODO) cluster running on [AWS](TODO), using [Terraform](TODO). It is the companion project to my article '[Creating a Resiliant Consul Cluster for Microservice Discovery on AWS with Terraform](TODO)'.

## Prerequisites

Please install the following components:

1. [Docker](https://docs.docker.com/engine/installation/mac)
0. [Terraform](https://www.terraform.io/intro/getting-started/install.html) - `brew update && brew install terraform`.

## Creating the Cluster

To create the cluster, register for an AWS account. You'll need to keep track of your *Secret Key* and *Access Key*. For instructions, see '[AWS Setup](TODO)'.

Now just run:

```bash
terraform apply
```

You will be asked to provide your Secret Key, Access Key and Region. When the provisioning is complete, you should see a message like:

```
TODO your cluster is ready! http://232.23.1.24:8000
```

Navigate to the URL provided and you will see the Consul interface, with some example microservices.

## Destroying the Cluster

Bring everything down with:

```
terraform destroy
```

## Project Structure

The project has the following structure:

```
variables.tf        # The basic terraform variables. Used in later files.
network.tf          # Network configuration. Defines the VPC, subnet, access etc.
cluster.tf          # Cluster configuration. Defines the Auto-scaling group, auto-scaling instance config etc.
microservices.tf    # Microservice configuration. Sample microservices which attempt to register themselves.
```

## Tasks

- [ ] Complete up to 'step 1', which is creating the network
- [ ] Complete up to 'step 2', which is creating the consul hosts (and ac)

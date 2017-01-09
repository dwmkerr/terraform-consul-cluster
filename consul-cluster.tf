// AMIs by region for AWS Optimised Linux
variable "ami_aws_linux" {
    description = "AMIs by region for AWS Optimised Linux 2016.09.1" 
    default = {
        us-east-1 = "ami-9be6f38c"
        us-east-2 = "ami-38cd975d"
        us-west-1 = "ami-1e299d7e"
        us-west-2 = "ami-b73d6cd7"
        ca-central-1 = "ami-eb20928f"
        eu-west-1 = "ami-c51e3eb6"
        eu-west-2 = "ami-bfe0eadb"
        eu-central-1 = "ami-211ada4e"
        ap-northeast-1 = "ami-9f0c67f8"
        ap-northeast-2 = "ami-94bb6dfa"
        ap-southeast-1 = "ami-4dd6782e"
        ap-southeast-2 = "ami-28cff44b"
        ap-south-1 = "ami-9fc7b0f0"
        sa-east-1 = "ami-bb40d8d7"
    }
}

//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_launch_configuration" "consul-cluster-lc" {
    name_prefix = "consul-node-"
    image_id = "${lookup(var.ami_aws_linux, var.region)}"
    instance_type = "t2.micro"
    user_data = "${file("files/consul-node.sh")}"
    iam_instance_profile = "${aws_iam_instance_profile.consul-instance-profile.id}"
    security_groups = [
        "${aws_security_group.consul-cluster-vpc.id}",
        "${aws_security_group.consul-cluster-public-web.id}",
        "${aws_security_group.consul-cluster-public-ssh.id}",
    ]
    lifecycle {
        create_before_destroy = true
    }
    key_name = "consul-cluster"
}

//  Load balancers for our consul cluster.
resource "aws_elb" "consul-lb" {
    name = "consul-lb"
    security_groups = [
        "${aws_security_group.consul-cluster-vpc.id}",
        "${aws_security_group.consul-cluster-public-web.id}",
    ]
    subnets = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]
    listener {
        instance_port = 8500
        instance_protocol = "http"
        lb_port = 8500
        lb_protocol = "http"
    }
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:8500/ui/"
        interval = 30
    }
}

//  Auto-scaling group for our cluster.
resource "aws_autoscaling_group" "consul-cluster-asg" {
    name = "consul-asg"
    launch_configuration = "${aws_launch_configuration.consul-cluster-lc.name}"
    min_size = 5
    max_size = 5
    vpc_zone_identifier = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]
    load_balancers = ["${aws_elb.consul-lb.name}"]
    lifecycle {
        create_before_destroy = true
    }
    tag {
        key = "Name"
        value = "Consul Node"
        propagate_at_launch = true
    }
    tag {
        key = "Project"
        value = "consul-cluster"
        propagate_at_launch = true
    }
}
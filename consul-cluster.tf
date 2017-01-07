//  AMI Images for ECS optimised linux.
variable "ami_ecs_optimised" {
    description = "AMI ids by region for ECS Optimised Linux"
    default = {
        us-east-1 = "ami-a88a46c5"
        us-west-1 = "ami-34a7e354"
        us-west-2 = "ami-ae0acdce"
        eu-west-1 = "ami-ccd942bf"
        eu-central-1 = "ami-4a5eb625"
        ap-northeast-1 = "ami-4aab5d2b"
        ap-southeast-1 = "ami-24c71547"
        ap-southeast-2 = "ami-0bf2da68"
    }
}

//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_launch_configuration" "consul-cluster-lc" {
    name_prefix = "consul-node-"
    image_id = "${lookup(var.ami_ecs_optimised, var.region)}"
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
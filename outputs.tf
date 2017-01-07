output "consul-dns" {
    value = "${aws_elb.consul-lb.dns_name}"
}
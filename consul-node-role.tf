resource "aws_iam_policy" "forward-logs" {
    name = "consul-node-forward-logs"
    path = "/"
    description = "Allows an instance to forward logs to CloudWatch"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}
    EOF
}

//  Create a role which consul instances will assume.
//  This role has a policy saying it can be assumed by ec2
//  instances.
resource "aws_iam_role" "consul-instance-role" {
    name = "consul-instance-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

//  Attach the policy to the role.
resource "aws_iam_policy_attachment" "consul-instance-forward-logs" {
    name = "consul-instance-leader-discovery-policy"
    roles = ["${aws_iam_role.consul-instance-role.name}"]
    policy_arn = "${aws_iam_policy.forward-logs.arn}"
}

//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "consul-instance-profile" {
    name = "consul-instance-profile"
    roles = ["${aws_iam_role.consul-instance-role.name}"]
}
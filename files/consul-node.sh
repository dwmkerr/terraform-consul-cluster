#!/bin/bash

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

# TODO: actually, userdata scripts run as root, so we can get
# rid of the sudo and tee...

# Update the packages, install CloudWatch tools.
sudo yum update -y
sudo yum install -y awslogs

# Create a config file for awslogs to log our user-data log.
cat <<- EOF | sudo tee /etc/awslogs/config/user-data.conf
	[/var/log/user-data.log]
	file = /var/log/user-data.log
	log_group_name = /var/log/user-data.log
	log_stream_name = {instance_id}
EOF

# Create a config file for awslogs to log our docker log.
cat <<- EOF | sudo tee /etc/awslogs/config/docker.conf
	[/var/log/docker]
	file = /var/log/docker
	log_group_name = /var/log/docker
	log_stream_name = {instance_id}
	datetime_format = %Y-%m-%dT%H:%M:%S.%f
EOF

# Start the awslogs service, also start on reboot.
# Note: Errors go to /var/log/awslogs.log
sudo service awslogs start
sudo chkconfig awslogs on

# Install the AWS CLI.
yum install -y aws-cli

# A few variables we will refer to later...
ASG_NAME=consul-asg
REGION=ap-southeast-1
EXPECTED_SIZE=5

# Install the AWS CLI.
yum install -y aws-cli

# Return the id of each instance in the cluster.
function cluster-instance-ids {
    # Grab every line which contains 'InstanceId', cut on double quotes and grab the ID:
    #    "InstanceId": "i-example123"
    #....^..........^..^.....#4.....^...
    aws --region="$REGION" autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME \
        | grep InstanceId \
        | cut -d '"' -f4
}

# Return the private IP of each instance in the cluster.
function cluster-ips {
    for id in $(cluster-instance-ids)
    do
        aws --region="$REGION" ec2 describe-instances \
            --query="Reservations[].Instances[].[PrivateIpAddress]" \
            --output="text" \
            --instance-ids="$id"
    done
}

# Wait until we have as many cluster instances as we are expecting.
while COUNT=$(cluster-instance-ids | wc -l) && [ "$COUNT" -lt "$EXPECTED_SIZE" ]
do
    echo "$COUNT instances in the cluster, waiting for $EXPECTED_SIZE instances to warm up..."
    sleep 1
done 

# Get my IP address and the initial leader IP address.
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
LEADER_IP=$(cluster-ips | sort | head -1)
echo "Instance IP is: $IP, Initial Leader IP is: $LEADER_IP"

# Start the Consul server.
docker run -d --net=host \
    --name=consul \
    consul agent -server -ui \
    -bind="$IP" -retry-join="$LEADER_IP" \
    -client="0.0.0.0" \
    -bootstrap-expect="$EXPECTED_SIZE"

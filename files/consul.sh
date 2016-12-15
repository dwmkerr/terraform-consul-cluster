#!/bin/bash

# consul.sh
#
# Sets up consul on a Amazon Linux Instance.
# 1. Wait until we can see X IP addresses for consul servers (by checking the auto-scaling group we are part of)
# 2. Find the lowest IP address, we'll call that the leader.
# 3. Start the server! If we are not the leader, join the leader ip.

# Log everything we do.
echo "Testing user data" >> /var/log/user-data.log
set -x
exec > /var/log/user-data.log 2>&1

ASG_NAME=consul-asg
REGION=ap-southeast-1
EXPECTED_SIZE=3

# Install the AWS CLI.
yum install -y aws-cli

# Return the id of each instance in the cluster.
function cluster-instance-ids {
    # Grab every line which contains 'InstanceId', cut on double quotes and grab the ID:
    #    "InstanceId": "i-example123"
    #1...|2.........|3.|4...........|5..
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
    -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
    consul agent -server -ui \
    -bind="$IP" -retry-join="$LEADER_IP" \
    -client="0.0.0.0" \
    -bootstrap-expect="$EXPECTED_SIZE"

# Start registrator.
docker run -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
    consul://localhost:8500

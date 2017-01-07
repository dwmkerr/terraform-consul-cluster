#!/bin/bash

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

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
	log_stream_name = {container_instance_id}
	datetime_format = %Y-%m-%dT%H:%M:%S.%f
EOF

# Start the awslogs service, also start on reboot.
# Note: Errors go to /var/log/awslogs.log
sudo service awslogs start
sudo chkconfig awslogs on

# Get my IP address.
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "Instance IP is: $IP"

# Start the Consul server.
docker run -d --net=host \
    --name=consul \
    consul agent -server -ui \
    -bind="$IP" \
    -client="0.0.0.0" \
    -bootstrap-expect="1"
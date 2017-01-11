#!/bin/bash

ASG_NAME="${asgname}"
REGION="${region}"
EXPECTED_SIZE="${size}"

export ASG_NAME
export REGION
export EXPECTED_SIZE

curl https://raw.githubusercontent.com/arehmandev/Consul-bashstrap/master/consul-node.sh | bash

echo "Bootstrap completed"

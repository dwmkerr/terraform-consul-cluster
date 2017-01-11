#!/bin/bash

export ASG_NAME="${asgname}"
export REGION="${region}"
export EXPECTED_SIZE="${size}"

curl https://raw.githubusercontent.com/arehmandev/Consul-bashstrap/master/consul-node.sh | sh

echo "Bootstrap completed"

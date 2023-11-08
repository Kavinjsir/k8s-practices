#!/usr/bin/env bash

# TODO: Missing best practices
# This script records commands to deploy a minikube cluster.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
# set -o pipefail

# 1. Deploy a single node cluster using Calico for CNI.
minikube start --network-plugin=cni --cni=calico

# 2. Add node
minikube node add

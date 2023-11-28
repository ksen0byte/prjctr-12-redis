#!/bin/bash
set -euo pipefail

source ./utils.sh

KEY_SIZE_KB=10
INIT_KEY_NUM=${1:-100}
EVICTION_KEY_NUM=${2:-100}
REDIS_MAXMEMORY="4mb"
EVICTION_POLICY="allkeys-random"

echo "-------------------------------------"
echo "Demonstrating the $EVICTION_POLICY eviction policy in Redis..."
echo "-------------------------------------"

redis_flush_db
redis_set_max_memory $REDIS_MAXMEMORY
redis_set_eviction_policy $EVICTION_POLICY

# Adding initial set of keys
redis_add_data "init" $INIT_KEY_NUM $KEY_SIZE_KB 

redis_check_memory_usage

# Trigger eviction by adding additional keys
redis_add_data "trigger" $EVICTION_KEY_NUM $KEY_SIZE_KB

redis_check_memory_usage

# Check which keys were evicted
echo "-------------------------------------"
echo "Verifying which keys were evicted..."
echo "-------------------------------------"
declare -A prefix_key_map
prefix_key_map["init"]=$INIT_KEY_NUM
prefix_key_map["trigger"]=$EVICTION_KEY_NUM
redis_keys_exist prefix_key_map

echo "-------------------------------------"
echo "Demonstration complete."
echo "-------------------------------------"

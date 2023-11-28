#!/bin/bash
set -euo pipefail

source ./utils.sh

KEY_SIZE_KB=10
VOLATILE_KEY_NUM=${1:-50}
NON_VOLATILE_KEY_NUM=${2:-50}
EVICTION_KEY_NUM=${3:-200}
REDIS_MAXMEMORY="4mb"
EVICTION_POLICY="volatile-random"

echo "-------------------------------------"
echo "Demonstrating the $EVICTION_POLICY eviction policy in Redis..."
echo "-------------------------------------"

redis_flush_db
redis_set_max_memory $REDIS_MAXMEMORY
redis_set_eviction_policy $EVICTION_POLICY

# Adding volatile and non-volatile keys
redis_add_data_with_expiration "volatile" $VOLATILE_KEY_NUM $KEY_SIZE_KB 60
redis_add_data "nonvolatile" $NON_VOLATILE_KEY_NUM $KEY_SIZE_KB

redis_check_memory_usage

# Trigger eviction by adding additional keys
redis_add_data "trigger" $EVICTION_KEY_NUM $KEY_SIZE_KB

redis_check_memory_usage

# Check which keys were evicted
echo "-------------------------------------"
echo "Verifying which keys were evicted..."
echo "-------------------------------------"
declare -A prefix_key_map
prefix_key_map["volatile"]=$VOLATILE_KEY_NUM
prefix_key_map["nonvolatile"]=$NON_VOLATILE_KEY_NUM
prefix_key_map["trigger"]=$EVICTION_KEY_NUM
redis_keys_exist prefix_key_map

echo "-------------------------------------"
echo "Demonstration complete."
echo "-------------------------------------"

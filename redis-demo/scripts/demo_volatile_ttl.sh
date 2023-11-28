#!/bin/bash
set -euo pipefail

source ./utils.sh

KEY_SIZE_KB=10
GROUP_KEY_NUM=${1:-25} # Number of keys per TTL group
NON_VOLATILE_KEY_NUM=${2:-50}
EVICTION_KEY_NUM=${3:-200}
REDIS_MAXMEMORY="4mb"
EVICTION_POLICY="volatile-ttl"
TTL_VALUES=(60 120 180 240) # Different TTL values for each group

echo "-------------------------------------"
echo "Demonstrating the $EVICTION_POLICY eviction policy in Redis..."
echo "-------------------------------------"

redis_flush_db
redis_set_max_memory $REDIS_MAXMEMORY
redis_set_eviction_policy $EVICTION_POLICY

# Adding volatile keys in groups for each TTL
for ttl in "${TTL_VALUES[@]}"; do
    redis_add_data_with_expiration "volatile-group-$ttl" $GROUP_KEY_NUM $KEY_SIZE_KB $ttl
done

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
for ttl in "${TTL_VALUES[@]}"; do
    prefix_key_map["volatile-group-$ttl"]=$GROUP_KEY_NUM
done
prefix_key_map["nonvolatile"]=$NON_VOLATILE_KEY_NUM
prefix_key_map["trigger"]=$EVICTION_KEY_NUM
redis_keys_exist prefix_key_map

echo "-------------------------------------"
echo "Demonstration complete."
echo "-------------------------------------"

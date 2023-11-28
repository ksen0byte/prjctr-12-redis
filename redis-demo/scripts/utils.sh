#!/bin/bash

generate_random_data() {
    local size_kb=$1
    local desired_bytes=$((size_kb * 1024))

    # Generate twice the amount initially to account for potential removal of nulls
    local initial_bytes=$((desired_bytes * 2))

    # Generate random data, remove nulls, and trim to the desired size
    head -c "${initial_bytes}" /dev/urandom | tr -d '\000' | head -c "${desired_bytes}"
}

redis_set_max_memory() {
    local max_memory=$1
    echo "-------------------------------------"
    echo "Setting maxmemory to ${max_memory}"
    echo "-------------------------------------"
    redis-cli -h redis-master -p 6379 CONFIG SET maxmemory $max_memory #> /dev/null
}

redis_set_eviction_policy() {
    local eviction_policy=$1
    echo "-------------------------------------"
    echo "Setting eviction policy to $eviction_policy"
    echo "-------------------------------------"
    redis-cli -h redis-master -p 6379 CONFIG SET maxmemory-policy $eviction_policy #> /dev/null
}

redis_flush_db() {
    echo "-------------------------------------"
    echo "Flushing all keys from the Redis database..."
    echo "-------------------------------------"
    redis-cli -h redis-master -p 6379 FLUSHDB #> /dev/null
}

redis_add_data() {
    local prefix=$1
    local number_of_keys=$2
    local size_in_kb=$3
    echo "-------------------------------------"
    echo "Adding [$number_of_keys] keys of size [${size_in_kb}kb] with prefix [$prefix]..."
    echo "-------------------------------------"
    for ((i=1; i<=number_of_keys; i++)); do
        local data=$(generate_random_data $size_in_kb)
        redis-cli -h redis-master -p 6379 SET "$prefix-key$i" "$data" > /dev/null
    done
}

redis_add_data_with_expiration() {
    local prefix=$1
    local number_of_keys=$2
    local size_in_kb=$3
    local expiration_in_seconds=$4
    echo "-------------------------------------"
    echo "Adding [$number_of_keys] keys of size [${size_in_kb}kb] with prefix [$prefix], expiration in [${expiration_in_seconds}s]..."
    echo "-------------------------------------"
    for ((i=1; i<=number_of_keys; i++)); do
        local data=$(generate_random_data $size_in_kb)
        redis-cli -h redis-master -p 6379 SET "$prefix-key$i" "$data" EX $expiration_in_seconds > /dev/null
    done
}

redis_check_memory_usage() {
    echo "-------------------------------------"
    echo "Keys total  : $(redis-cli -h redis-master -p 6379 DBSIZE)"
    echo "Memory usage: $(redis-cli -h redis-master -p 6379 INFO memory | grep used_memory_human)"
    echo "-------------------------------------"
}

redis_get_keys() {
    local prefix=$1
    local number_of_keys=$2
    echo "-------------------------------------"
    echo "Getting [$number_of_keys] keys with prefix [$prefix]..."
    echo "-------------------------------------"
    for ((i=1; i<=number_of_keys; i++)); do
        redis-cli -h redis-master -p 6379 GET "$prefix-key$i" > /dev/null # && echo "$prefix-key$i: OK"
    done
}

redis_keys_exist() {
    local -n key_map=$1
    for prefix in "${!key_map[@]}"; do
        keys_total=${key_map[$prefix]}
        command="redis-cli -h redis-master -p 6379 EXISTS"
        
        for ((i=1; i<=keys_total; i++)); do
            command+=" ${prefix}-key$i"
        done

        local existing_keys_total=$(eval "$command")
        echo "-------------------------------------"
        echo "Prefix [$prefix] | keys [$keys_total] | existing keys [$existing_keys_total] | evicted keys [$((keys_total - existing_keys_total))]"
        echo "-------------------------------------"
    done
}
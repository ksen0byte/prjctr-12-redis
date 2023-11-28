#!/bin/bash

declare -A local_cache
CACHE_PROBABILITY=80  # Probability in percentage to use the cache

# Initialize Redis connection parameters
REDIS_HOST="redis-master"
REDIS_PORT=6379

# Function to fetch data from Redis
fetch_from_redis() {
    local key=$1
    redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" GET "$key"
}

# Function to get data with caching logic
cache_get() {
    local key=$1
    local should_use_cache=$(( RANDOM % 100 < CACHE_PROBABILITY ))

    if [[ $should_use_cache -eq 1 ]] && [[ -n "${local_cache[$key]}" ]]; then
        echo "${local_cache[$key]}"
    else
        local value=$(fetch_from_redis "$key")
        local_cache[$key]=$value
        echo "$value"
    fi
}

# Function to set data in Redis and update local cache
cache_set() {
    local key=$1
    local value=$2
    redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" SET "$key" "$value"
    local_cache[$key]=$value
}

# Example Usage
cache_set "hello" "world"
echo $(cache_get "hello")  # There's an 80% chance this will use the local cache

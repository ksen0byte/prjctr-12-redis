#!/bin/bash

set -euox pipefail

echo "Writing key1 to Master"
redis-cli -h redis-master -p 6379 SET key1 "Hello from Master"

echo "Read from Master:"
redis-cli -h redis-master -p 6379 GET key1

echo "Read from Replica 1:"
redis-cli -h redis-replica1 -p 6379 GET key1

echo "Read from Replica 2:"
redis-cli -h redis-replica2 -p 6379 GET key1

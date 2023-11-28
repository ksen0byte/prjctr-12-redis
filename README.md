# Redis Setup & Eviction Policies Demo

To run:
```bash
docker compose up -d
```

## Demo Scripts

Source code for demo scripts is located at [./redis-demo/scripts](./redis-demo/scripts).

## UI

UI can be accessed at [localhost:7843](http://localhost:7843/).

## Basic Redis

To run:
```bash
docker compose run redis-demo ./demo_redis_basic.sh
```

Result:
```bash
+ echo 'Writing key1 to Master'
Writing key1 to Master
+ redis-cli -h redis-master -p 6379 SET key1 'Hello from Master'
OK
+ echo 'Read from Master:'
Read from Master:
+ redis-cli -h redis-master -p 6379 GET key1
"Hello from Master"
+ echo 'Read from Replica 1:'
Read from Replica 1:
+ redis-cli -h redis-replica1 -p 6379 GET key1
"Hello from Master"
+ echo 'Read from Replica 2:'
Read from Replica 2:
+ redis-cli -h redis-replica2 -p 6379 GET key1
"Hello from Master"
```

## Sentinel Setup

To run test failover you could either `docker pause` a redis master container or run the following demo script:
```bash
docker compose run redis-demo ./demo_sentinel_failover.sh4
```

Result:
```bash
-------------------------------------
1. Checking current master
-------------------------------------
-------------------------------------
Fetching master info...
-------------------------------------
IP: 172.26.0.2
Port: 6379
Flags: master
Number of Slaves: 2
-------------------------------------
2. Triggering failover
-------------------------------------
OK
Failover initiated, waiting for completion...
-------------------------------------
3. Checking new master after failover
-------------------------------------
-------------------------------------
Fetching master info...
-------------------------------------
IP: 172.26.0.3
Port: 6379
Flags: master
Number of Slaves: 2
-------------------------------------
4. Checking the status of all replicas
-------------------------------------
name  172.26.0.2:6379
flags slave
name  172.26.0.6:6379
flags slave
```

## Eviction Policies

### `noeviction`

New values aren’t saved when memory limit is reached. When a database uses replication, this applies to the primary database.

To run [demo_noeviction.sh](./redis-demo/scripts/demo_noeviction.sh):
```bash
docker compose run redis-demo ./demo_noeviction.sh
```

Result:
```bash
-------------------------------------
Demonstrating the noeviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to noeviction
-------------------------------------
OK
-------------------------------------
Adding data to Redis...
-------------------------------------
Out of memory error returned after 1155 writes.
-------------------------------------
Getting DBSIZE from Redis...
-------------------------------------
(integer) 1154
-------------------------------------
Demonstration complete.
-------------------------------------
```


### `allkeys-lru`

Keeps most recently used keys; removes least recently used (LRU) keys.

To run [demo_allkeys_lru.sh](./redis-demo/scripts/demo_allkeys_lru.sh):
```bash
docker compose run redis-demo ./demo_allkeys_lru.sh
```

Result:
```bash
-------------------------------------
Demonstrating the allkeys-lru eviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to allkeys-lru
-------------------------------------
OK
-------------------------------------
Adding [100] keys of size [10kb] with prefix [init]...
-------------------------------------
-------------------------------------
Keys total  : 100
Memory usage: used_memory_human:3.73M
-------------------------------------
-------------------------------------
Getting [100] keys with prefix [init]...
-------------------------------------
-------------------------------------
Adding [200] keys of size [10kb] with prefix [trigger]...
-------------------------------------
-------------------------------------
Keys total  : 123
Memory usage: used_memory_human:4.00M
-------------------------------------
-------------------------------------
Verifying which keys were evicted...
-------------------------------------
-------------------------------------
Prefix [init] | keys [100] | existing keys [42] | evicted keys [58]
-------------------------------------
-------------------------------------
Prefix [trigger] | keys [200] | existing keys [81] | evicted keys [119]
-------------------------------------
-------------------------------------
Demonstration complete.
-------------------------------------
```

### `allkeys-lfu`

Keeps frequently used keys; removes least frequently used (LFU) keys.

To run [demo_allkeys_lfu.sh](./redis-demo/scripts/demo_allkeys_lfu.sh):
```bash
docker compose run redis-demo ./demo_allkeys_lfu.sh
```

Result:
```bash
-------------------------------------
Demonstrating the allkeys-lfu eviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to allkeys-lfu
-------------------------------------
OK
-------------------------------------
Adding [100] keys of size [10kb] with prefix [init]...
-------------------------------------
-------------------------------------
Keys total  : 100
Memory usage: used_memory_human:3.71M
-------------------------------------
-------------------------------------
Getting [100] keys with prefix [init]...
-------------------------------------
-------------------------------------
Adding [200] keys of size [10kb] with prefix [trigger]...
-------------------------------------
-------------------------------------
Keys total  : 123
Memory usage: used_memory_human:3.99M
-------------------------------------
-------------------------------------
Verifying which keys were evicted...
-------------------------------------
-------------------------------------
Prefix [init] | keys [100] | existing keys [92] | evicted keys [8]
-------------------------------------
-------------------------------------
Prefix [trigger] | keys [200] | existing keys [31] | evicted keys [169]
-------------------------------------
-------------------------------------
Demonstration complete.
-------------------------------------
```

### `volatile_lru`

Removes least recently used keys with the expire field set to true.

To run [demo_volatile_lru.sh](./redis-demo/scripts/demo_volatile_lru.sh):
```bash
docker compose run redis-demo ./demo_volatile_lru.sh
```

Result:
```bash
-------------------------------------
Demonstrating the volatile-lru eviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to volatile-lru
-------------------------------------
OK
-------------------------------------
Adding [50] keys of size [10kb] with prefix [volatile]...
-------------------------------------
-------------------------------------
Adding [50] keys of size [10kb] with prefix [nonvolatile]...
-------------------------------------
-------------------------------------
Keys total  : 100
Memory usage: used_memory_human:3.71M
-------------------------------------
-------------------------------------
Getting [50] keys with prefix [volatile]...
-------------------------------------
-------------------------------------
Adding [200] keys of size [10kb] with prefix [trigger]...
-------------------------------------
-------------------------------------
Keys total  : 125
Memory usage: used_memory_human:4.01M
-------------------------------------
-------------------------------------
Verifying which keys were evicted...
-------------------------------------
-------------------------------------
Prefix [nonvolatile] | keys [50] | existing keys [50] | evicted keys [0]
-------------------------------------
-------------------------------------
Prefix [volatile] | keys [50] | existing keys [0] | evicted keys [50]
-------------------------------------
-------------------------------------
Prefix [trigger] | keys [200] | existing keys [75] | evicted keys [125]
-------------------------------------
-------------------------------------
Demonstration complete.
-------------------------------------
```

### `volatile_lfu`

Removes least frequently used keys with the expire field set to true.

To run [demo_volatile_lfu.sh](./redis-demo/scripts/demo_volatile_lfu.sh):
```bash
docker compose run redis-demo ./demo_volatile_lfu.sh
```

Result:
```bash
-------------------------------------
Demonstrating the volatile-lfu eviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to volatile-lfu
-------------------------------------
OK
-------------------------------------
Adding [50] keys of size [10kb] with prefix [volatile]...
-------------------------------------
-------------------------------------
Adding [50] keys of size [10kb] with prefix [nonvolatile]...
-------------------------------------
-------------------------------------
Keys total  : 100
Memory usage: used_memory_human:3.74M
-------------------------------------
-------------------------------------
Getting [50] keys with prefix [volatile]...
-------------------------------------
-------------------------------------
Adding [200] keys of size [10kb] with prefix [trigger]...
-------------------------------------
-------------------------------------
Keys total  : 125
Memory usage: used_memory_human:4.03M
-------------------------------------
-------------------------------------
Verifying which keys were evicted...
-------------------------------------
-------------------------------------
Prefix [nonvolatile] | keys [50] | existing keys [50] | evicted keys [0]
-------------------------------------
-------------------------------------
Prefix [volatile] | keys [50] | existing keys [0] | evicted keys [50]
-------------------------------------
-------------------------------------
Prefix [trigger] | keys [200] | existing keys [75] | evicted keys [125]
-------------------------------------
-------------------------------------
Demonstration complete.
-------------------------------------
```

### `allkeys-random`

Randomly removes keys to make space for the new data added.

To run [demo_allkeys_random.sh](./redis-demo/scripts/demo_allkeys_random.sh):
```bash
docker compose run redis-demo ./demo_allkeys_random.sh
```

Result:
```bash
-------------------------------------
Demonstrating the allkeys-random eviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to allkeys-random
-------------------------------------
OK
-------------------------------------
Adding [100] keys of size [10kb] with prefix [init]...
-------------------------------------
-------------------------------------
Keys total  : 100
Memory usage: used_memory_human:3.73M
-------------------------------------
-------------------------------------
Adding [100] keys of size [10kb] with prefix [trigger]...
-------------------------------------
-------------------------------------
Keys total  : 125
Memory usage: used_memory_human:4.01M
-------------------------------------
-------------------------------------
Verifying which keys were evicted...
-------------------------------------
-------------------------------------
Prefix [init] | keys [100] | existing keys [58] | evicted keys [42]
-------------------------------------
-------------------------------------
Prefix [trigger] | keys [100] | existing keys [67] | evicted keys [33]
-------------------------------------
-------------------------------------
Demonstration complete.
-------------------------------------
```

### `volatile-random`

Randomly removes keys with expire field set to true.

To run [demo_volatile_random.sh](./redis-demo/scripts/demo_volatile_random.sh):
```bash
docker compose run redis-demo ./demo_volatile_random.sh
```

Result:
```bash
-------------------------------------
Demonstrating the volatile-random eviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to volatile-random
-------------------------------------
OK
-------------------------------------
Adding [50] keys of size [10kb] with prefix [volatile]...
-------------------------------------
-------------------------------------
Adding [50] keys of size [10kb] with prefix [nonvolatile]...
-------------------------------------
-------------------------------------
Keys total  : 100
Memory usage: used_memory_human:3.71M
-------------------------------------
-------------------------------------
Adding [200] keys of size [10kb] with prefix [trigger]...
-------------------------------------
-------------------------------------
Keys total  : 125
Memory usage: used_memory_human:4.03M
-------------------------------------
-------------------------------------
Verifying which keys were evicted...
-------------------------------------
-------------------------------------
Prefix [nonvolatile] | keys [50] | existing keys [50] | evicted keys [0]
-------------------------------------
-------------------------------------
Prefix [volatile] | keys [50] | existing keys [0] | evicted keys [50]
-------------------------------------
-------------------------------------
Prefix [trigger] | keys [200] | existing keys [75] | evicted keys [125]
-------------------------------------
-------------------------------------
Demonstration complete.
-------------------------------------
```

### `volatile-ttl`

Removes keys with expire field set to true and the shortest remaining time-to-live (TTL) value.

To run [demo_volatile_ttl.sh](./redis-demo/scripts/demo_volatile_ttl.sh):
```bash
docker compose run redis-demo ./demo_volatile_ttl.sh
```

Result:
```bash
-------------------------------------
Demonstrating the volatile-ttl eviction policy in Redis...
-------------------------------------
-------------------------------------
Flushing all keys from the Redis database...
-------------------------------------
OK
-------------------------------------
Setting maxmemory to 4mb
-------------------------------------
OK
-------------------------------------
Setting eviction policy to volatile-ttl
-------------------------------------
OK
-------------------------------------
Adding [10] keys of size [10kb] with prefix [volatile-group-60], expiration in [60s]...
-------------------------------------
-------------------------------------
Adding [10] keys of size [10kb] with prefix [volatile-group-120], expiration in [120s]...
-------------------------------------
-------------------------------------
Adding [10] keys of size [10kb] with prefix [volatile-group-180], expiration in [180s]...
-------------------------------------
-------------------------------------
Adding [10] keys of size [10kb] with prefix [volatile-group-240], expiration in [240s]...
-------------------------------------
-------------------------------------
Adding [40] keys of size [10kb] with prefix [nonvolatile]...
-------------------------------------
-------------------------------------
Keys total  : 80
Memory usage: used_memory_human:3.48M
-------------------------------------
-------------------------------------
Adding [60] keys of size [10kb] with prefix [trigger]...
-------------------------------------
-------------------------------------
Keys total  : 125
Memory usage: used_memory_human:4.03M
-------------------------------------
-------------------------------------
Verifying which keys were evicted...
-------------------------------------
-------------------------------------
Prefix [volatile-group-240] | keys [10] | existing keys [10] | evicted keys [0]
-------------------------------------
-------------------------------------
Prefix [volatile-group-60] | keys [10] | existing keys [0] | evicted keys [10]
-------------------------------------
-------------------------------------
Prefix [nonvolatile] | keys [40] | existing keys [40] | evicted keys [0]
-------------------------------------
-------------------------------------
Prefix [volatile-group-180] | keys [10] | existing keys [10] | evicted keys [0]
-------------------------------------
-------------------------------------
Prefix [trigger] | keys [60] | existing keys [60] | evicted keys [0]
-------------------------------------
-------------------------------------
Prefix [volatile-group-120] | keys [10] | existing keys [5] | evicted keys [5]
-------------------------------------
-------------------------------------
Demonstration complete.
-------------------------------------
```

## Probabilistic Cache

To run [demo_probabilistic_cache_wrapper.sh](./redis-demo/scripts/demo_probabilistic_cache_wrapper.sh):
```bash
docker compose run redis-demo ./demo_probabilistic_cache_wrapper.sh
```

Result:

```bash
OK
world
```
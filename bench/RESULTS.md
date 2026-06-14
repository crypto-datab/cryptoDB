# NEDB Benchmark Results

**Version:** `0.4.1`  
**Python:** `3.9.25`  
**Platform:** `Linux x86_64`  
**Date:** `2026-06-14`  

> Run: `python3 bench/benchmarks.py --save`

---

### Core operations

| Operation | Throughput | Latency (avg) |
|-----------|-----------|---------------|
| PUT (replace, no index) | 63.5K/s | 15.74 µs |
| GET (point read, HEAD) | 1.33M/s | 0.75 µs |
| GET (AS OF — time-travel) | 942.9K/s | 1.06 µs |

### Index performance

| Operation | Throughput | Latency (avg) |
|-----------|-----------|---------------|
| QUERY: eq filter, no index (scan) | 514.1K/s | 1.95 µs |
| QUERY: eq filter, eq index | 1.45M/s | 0.69 µs |
| QUERY: ORDER BY, ordered index, LIMIT 20 | 454.7K/s | 2.20 µs |
| QUERY: SEARCH, inverted index | 492.3K/s | 2.03 µs |

### Adapter overhead (SQL · Redis · AutoIndex)

| Operation | Throughput | Latency (avg) |
|-----------|-----------|---------------|
| NQL: WHERE eq (raw) | 1.93M/s | 0.52 µs |
| SQL: SELECT WHERE (adapter → NQL) | 1.73M/s | 0.58 µs |
| Redis: HSET ×10 (adapter) | 50.6K/s | 19.75 µs |
| Redis: HGET ×10 (adapter) | 303.3K/s | 3.30 µs |
| AutoIndexDB: same query via wrapper | 1.87M/s | 0.54 µs |

### Persistence: in-memory vs AOF

| Operation | Throughput | Latency (avg) |
|-----------|-----------|---------------|
| PUT in-memory (no AOF) | 71.3K/s | 14.02 µs |
| PUT durable (AOF + fsync) | 7.3K/s | 137.59 µs |
| RELOAD from AOF (1000 ops) | — | 31.9 ms total |

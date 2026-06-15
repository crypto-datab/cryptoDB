#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# NEDB × RESP2 — redis-cli talking to a time-traveling, tamper-evident database
#
# What you need:
#   pip install nedb-engine
#   NEDBD_RESP2_PORT=6380 nedbd --data /tmp/nedb-demo  (in another terminal)
#
# Or start inline:
#   NEDBD_RESP2_PORT=6380 NEDBD_DATA=/tmp/nedb-demo nedbd &
#
# Then run this script.
# ─────────────────────────────────────────────────────────────────────────────

HOST=127.0.0.1
PORT=6380
CLI="redis-cli -h $HOST -p $PORT"

echo ""
echo "  ◆ NEDB via redis-cli — no Redis installation required"
echo "  ─────────────────────────────────────────────────────"
echo ""

# ── 1. It's just Redis ────────────────────────────────────────────────────────
echo "  [1/6] Standard Redis commands work exactly as expected"
echo ""

$CLI PING
$CLI SELECT salon            # select a database BY NAME (not a number!)
$CLI SELECT salon SET owner "INTERCHAINED LLC"
$CLI SELECT salon GET owner

echo ""
$CLI SELECT salon HSET client:001 name "Mia Thornton" status active phone "555-0101"
$CLI SELECT salon HSET client:002 name "James Okafor"  status active phone "555-0102"
$CLI SELECT salon HSET client:003 name "Sofia Reyes"   status inactive phone "555-0103"
$CLI SELECT salon HGETALL client:001
$CLI SELECT salon DBSIZE

echo ""
echo "  [2/6] Sets, lists — all Redis data structures"
echo ""
$CLI SELECT salon SADD tags:client:001 vip loyal regular
$CLI SELECT salon SMEMBERS tags:client:001
$CLI SELECT salon RPUSH appointments:queue "Mon 9am" "Tue 2pm" "Wed 11am"
$CLI SELECT salon LRANGE appointments:queue 0 -1

# ── 2. NQL via EVAL — the superpower ─────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────────────"
echo "  [3/6] NQL via EVAL — this is where it gets different"
echo "  ─────────────────────────────────────────────────────"
echo ""

# Seed some structured data first
$CLI SELECT nedb EVAL 'FROM users' 0   # will be empty — that's fine

# Use Python API to seed, then query via redis-cli
python3 - <<'PYEOF'
import sys; sys.path.insert(0, "python")
from nedb import NEDB
db = NEDB("/tmp/nedb-demo/nedb")
db.create_index("users", "status", "eq")
db.create_index("users", "bio", "search")
for u in [
    ("alice", "Alice",  31, "active",   "rust systems hacker"),
    ("bob",   "Bob",    24, "active",   "python data scientist"),
    ("carol", "Carol",  41, "inactive", "rust embedded engineer"),
    ("dave",  "Dave",   28, "active",   "go distributed systems"),
]:
    db.put("users", u[0], {"name": u[1], "age": u[2], "status": u[3], "bio": u[4]})
print(f"  seeded {db.seq+1} users — seq={db.seq}")
PYEOF

echo ""
echo "  Querying with NQL via redis-cli EVAL:"
echo ""

# FROM + WHERE + ORDER BY
$CLI -p $PORT SELECT nedb EVAL 'FROM users WHERE status = "active" ORDER BY age ASC' 0

echo ""
# Full-text search
$CLI -p $PORT SELECT nedb EVAL 'FROM users SEARCH "rust"' 0

echo ""
# GROUP BY aggregation
$CLI -p $PORT SELECT nedb EVAL 'FROM users GROUP BY status COUNT' 0

# ── 3. Time travel ────────────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────────────"
echo "  [4/6] Time-travel — AS OF any past sequence"
echo "  ─────────────────────────────────────────────────────"
echo ""

# Get current seq via python, then update alice, then query as-of snapshot
python3 - <<'PYEOF'
import sys; sys.path.insert(0, "python")
from nedb import NEDB
db = NEDB("/tmp/nedb-demo/nedb")
snap = db.seq
db.put("users", "alice", {"name": "Alice", "age": 99, "status": "retired", "bio": "now on sabbatical"})
print(f"  snapshot={snap}  updated alice → age=99, status=retired")
print(f"  Run: EVAL 'FROM users AS OF {snap} WHERE _id = \"alice\"' 0")
PYEOF

echo ""
echo "  (Run the EVAL above to see alice at her original age)"

# ── 4. Causal provenance via TRACE ───────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────────────"
echo "  [5/6] Causal provenance — TRACE from redis-cli"
echo "  ─────────────────────────────────────────────────────"
echo ""

python3 - <<'PYEOF'
import sys; sys.path.insert(0, "python")
from nedb import NEDB
db = NEDB("/tmp/nedb-demo/nedb")
db.put("kb", "msg_1", {"text": "user said: prefer dark mode"})
s1 = db.seq
db.put("beliefs", "dark_mode",
    {"value": True, "summary": "User prefers dark mode"},
    caused_by=[s1], evidence="user_message", confidence=0.95)
print(f"  wrote msg_1 at seq={s1}, derived belief 'dark_mode' from it")
print(f"  Run: EVAL 'FROM beliefs WHERE _id = \"dark_mode\" TRACE caused_by' 0")
PYEOF

echo ""
$CLI -p $PORT SELECT nedb EVAL 'FROM beliefs WHERE _id = "dark_mode" TRACE caused_by' 0

# ── 5. Verify the chain ───────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────────────"
echo "  [6/6] Tamper evidence — verify the hash chain"
echo "  ─────────────────────────────────────────────────────"
echo ""

python3 - <<'PYEOF'
import sys; sys.path.insert(0, "python")
from nedb import NEDB
db = NEDB("/tmp/nedb-demo/nedb")
ok = db.verify()
print(f"  chain verify: {ok}  head: {db.head[:20]}…  seq: {db.seq}")
print(f"  {'✅ not a single op has been tampered with' if ok else '❌ chain is broken'}")
PYEOF

echo ""
echo "  ─────────────────────────────────────────────────────"
echo "  That was a hash-chained, MVCC, time-traveling,"
echo "  replay-protected, causally-provable database"
echo "  — queried entirely with redis-cli."
echo "  ─────────────────────────────────────────────────────"
echo ""

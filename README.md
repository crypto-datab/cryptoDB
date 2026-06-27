<h1 align="center">crypto-database</h1>
<p align="center"><b>The database that can prove it never lied.</b></p>

---

crypto-database is a **content-addressed, hash-chained, time-traveling** datastore. Every version of every record is an immutable, **BLAKE2b-verified** object in a Merkle DAG — nothing is ever overwritten, and the store can prove its own integrity on demand.

If your data is evidence — ledgers, audit trails, provenance, anything you may one day have to *defend* — crypto-database makes the history itself tamper-evident and replayable.

## Why crypto-database

- 🔒 **Tamper-evident by construction.** `verify()` re-hashes every object against its content address. Flip a single byte on disk and it's caught — silently impossible to forge history.
- ⏪ **Time-travel is a query.** `AS OF <seq>` returns the exact state at any point. `VALID AS OF <time>` adds bi-temporal validity — *what was true, as of when.*
- 🧬 **Causal provenance.** `caused_by` links every record to the facts that produced it; `TRACE` walks the graph. Audit **why**, not just **what**.
- 🔐 **Encrypted at rest** (AES-256-GCM), RESP2 wire protocol, SQL / Redis / Mongo adapters, a `nedbd-v2` server daemon.

## Install

```bash
npm install crypto-database   # Node (native addon)
pip install cryptodb          # Python  ← note the PyPI name
cargo add crypto-database     # Rust
```

> **Why the split name?** `crypto-database` was already taken on PyPI by an unrelated project, so the Python distribution keeps the original `cryptodb` name there. npm and crates.io publish as `crypto-database`. Same engine, same version, same code — only the registry labels differ.

## Reach for it when

Audit logs · financial & token ledgers · compliance trails · supply-chain provenance · anything where **provable, replayable history is the product**, not a nice-to-have.

```js
import { NedbCore } from "crypto-database";
const db = new NedbCore();
db.put("ledger", "acct:alice", JSON.stringify({ balance: 100 }));
db.put("ledger", "acct:alice", JSON.stringify({ balance: 250 }));
db.getAsOf("ledger", "acct:alice", 0n);   // → balance 100, the past, intact
db.verify();                               // → true: nothing was tampered
```

---

<sub>crypto-database (previously `CryptoDB`) is a distribution of the **NEDB** engine, tuned for verifiability. Engine development happens upstream at [Eth-Interchained/nedb](https://github.com/Eth-Interchained/nedb). © Interchained LLC.</sub>

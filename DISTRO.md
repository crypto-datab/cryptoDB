# crypto-database — distribution notes

- **Identity:** The verifiable v2/v3 distribution of NEDB: content-addressed Merkle DAG, AS OF time-travel, causal provenance, BLAKE2b tamper-evidence.
- **Relationship to nedb-engine:** identical core today; renamed for npm/crates so it publishes as `crypto-database`.
- **Registry split (important):** `crypto-database` on npm + crates.io, but `cryptodb` on PyPI — `crypto-database` was already taken on PyPI by an unrelated third-party project. Same engine, same version, same code; only the PyPI label stays `cryptodb`.
- **Planned divergence:** per-distro *defaults* (no flags required) land in `rust/crates/crypto-database/src/lib.rs` and the Python/JS shims.
- **Builds:** driven by the central `nedb` release workflow via submodule; this repo carries no workflow of its own.

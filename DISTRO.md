# cryptodb — distribution notes

- **Identity:** The verifiable v2/v3 distribution of NEDB: content-addressed Merkle DAG, AS OF time-travel, causal provenance, BLAKE2b tamper-evidence.
- **Relationship to nedb-engine:** identical core today; renamed for npm/PyPI/crates so it publishes as `cryptodb`.
- **Planned divergence:** per-distro *defaults* (no flags required) land in `rust/crates/cryptodb/src/lib.rs` and the Python/JS shims.
- **Builds:** driven by the central `nedb` release workflow via submodule; this repo carries no workflow of its own.

//! crypto-database
//!
//! The verifiable v2/v3 distribution of NEDB: content-addressed Merkle DAG, AS OF time-travel, causal provenance, BLAKE2b tamper-evidence.
//!
//! Identical to `nedb-engine` today; this crate is the distribution seam where
//! crypto-database-specific defaults will land (no flags) in a later release.
pub use nedb_engine::*;

//! crypto-database
//!
//! The verifiable v2/v3 distribution of NEDB: content-addressed Merkle DAG, AS OF time-travel, causal provenance, BLAKE2b tamper-evidence.
//!
//! Re-exports the full `nedb-engine` API unchanged. crypto-database's
//! distribution defaults — the verifiable v3 segment store (content-addressed,
//! self-verifying; AS OF / TRACE time-travel) — are applied by setting the
//! engine's existing env knobs before a `Db` is opened: programmatically via
//! [`apply_distro_defaults`], and automatically by the npm `main` shim and the
//! `nedbd-v2` daemon shim. No engine fork, no flags.
pub use nedb_engine::*;

/// Apply crypto-database's default engine modes — the verifiable v3 segment
/// store — unless the caller has already chosen. Call once before opening a
/// [`Db`]. Set-if-unset: an explicit `NEDB_DAG_V3` (including `0`) always wins.
pub fn apply_distro_defaults() {
    if std::env::var_os("NEDB_DAG_V3").is_none() {
        std::env::set_var("NEDB_DAG_V3", "1");
    }
}

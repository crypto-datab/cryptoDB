"use strict";
// crypto-database — distribution defaults.
//
// The verifiable v2/v3 distribution defaults to the content-addressed v3
// segment store (self-verifying objects; AS OF / TRACE time-travel). These
// defaults are applied by setting the engine's existing env knobs BEFORE the
// native addon opens any database — the engine reads them at open time.
//
// Set-if-unset: an explicit value always wins, so `NEDB_DAG_V3=0` opts out.
if (process.env.NEDB_DAG_V3 === undefined) process.env.NEDB_DAG_V3 = "1";

module.exports = require("./index.js");

// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("gzipTest") struct gzipTest : ShellTest {
  let cmd = "gzip"
  let suiteBundle = "file_cmds_gzipTest"
  
  @Test func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

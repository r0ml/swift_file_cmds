// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026


import ShellTesting

@Suite("cksumTest") struct cksumTest : ShellTest {
  let cmd = "cksum"
  let suiteBundle = "file_cmds_cksumTest"
  
  @Test func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

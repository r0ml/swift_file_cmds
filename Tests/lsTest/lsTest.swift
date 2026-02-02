// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("lsTest") struct lsTest : ShellTest {
  let cmd = "ls"
  let suiteBundle = "file_cmds_lsTest"
  
  @Test func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

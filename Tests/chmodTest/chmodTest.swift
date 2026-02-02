// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("chmodTest") struct chmodTest : ShellTest {
  let cmd = "chmod"
  let suiteBundle = "file_cmds_chmodTest"
  
  @Test func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

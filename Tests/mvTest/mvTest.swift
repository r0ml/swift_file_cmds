// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("mvTest") struct mvTest : ShellTest {
  let cmd = "mv"
  let suiteBundle = "file_cmds_mvTest"
  
  @Test func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

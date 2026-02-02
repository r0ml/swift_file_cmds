// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("duTest") struct duTest : ShellTest {
  let cmd = "du"
  let suiteBundle = "file_cmds_duTest"
  
  @Test func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

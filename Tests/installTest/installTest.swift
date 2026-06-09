// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("installTest") struct installTest : ShellTest {
  let cmd = "install"
  let suiteBundle = "file_cmds_installTest"
  
  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

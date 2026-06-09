// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("chownTest") struct chownTest : ShellTest {
  let cmd = "chown"
  let suiteBundle = "file_cmds_chownTest"
  
  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("dfTest") struct dfTest : ShellTest {
  let cmd = "df"
  let suiteBundle = "file_cmds_dfTest"
  
  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

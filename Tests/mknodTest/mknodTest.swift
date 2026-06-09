// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026


// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

@Suite("mknodTest") struct mknodTest : ShellTest {
  let cmd = "mknod"
  let suiteBundle = "file_cmds_mknodTest"

  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

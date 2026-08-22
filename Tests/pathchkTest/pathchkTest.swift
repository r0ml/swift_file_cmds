// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026

import Foundation

import ShellTesting

@Suite("pathchkTest") struct pathchkTest : ShellTest {
  let cmd = "pathchk"
  let suiteBundle = "file_cmds_pathchkTest"

  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}


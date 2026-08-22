// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026

import ShellTesting

@Suite("mkfifoTest") struct mkfifoTest : ShellTest {
  let cmd = "mkfifo"
  let suiteBundle = "file_cmds_mkfifoTest"

  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

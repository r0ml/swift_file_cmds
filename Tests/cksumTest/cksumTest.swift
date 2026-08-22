// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026


import ShellTesting

@Suite("cksumTest") struct cksumTest : ShellTest {
  let cmd = "cksum"
  let suiteBundle = "file_cmds_cksumTest"
  
  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}

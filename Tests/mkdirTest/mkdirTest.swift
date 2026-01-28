// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

struct mkdirTest : ShellTest {
  var cmd = "mkdir"
  var suiteBundle = "mkdirTest"

  @Test("Verify that an invalid usage with a supported option produces a valid error message", arguments: [
    "-p", "-v"
  ]) func nofiles(_ f : String) async throws {
    try await run(status: 1, error: /usage: mkdir/, args: f)
  }

  @Test("Verify that an invalid usage with a supported option produces a valid error message") func argm() async throws {
    try await run(status: 1, error: /mkdir: options requires an argument/, args: "-m")
  }

  @Test("Verify that mkdir(1) fails and generates a valid usage message when no arguments are supplied") func noargs() async throws {
    try await run(status: 1, error: /usage: mkdir/)
  }
}

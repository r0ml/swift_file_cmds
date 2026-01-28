// Modernized by Robert "r0ml" Lefkowitz <r0ml@liberally.net> in 2025
// from a file containing the following notice:

/*
# Copyright 2017 Shivansh Rai
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
*/

import ShellTesting

struct chflagsTest : ShellTest {
  var cmd = "chflags"
  var suiteBundle = "chflagsTest"

  @Test("Verify that an invalid usage with a supported option produces a valid error message", arguments: [
    "-f", "-H", "-h", "-L"
  ]) func nofiles(_ f : String) async throws {
    try await run(status: 1, error: /usage: chflags/, args: f)
    }

  @Test("change a flag") func changeFlag() async throws {
    let k = try tmpfile("test", "Test file")
    defer { rm(k) }
    try await run(output: "test: 00 -> 01\n", args: "-v", "-v", "nodump", k)
  }
}

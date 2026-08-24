// Modernized by Robert M. Lefkowitz <r0ml@liberally.net> in 2025 using an LLM
// from a file containing the following notice:

/*
 #
 # SPDX-License-Identifier: BSD-2-Clause
 #
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
 #
 */

import ShellTesting
import CMigration

struct lnTest : ShellTest {
  var cmd = "ln"
  var suiteBundle = "file_cmds_lnTest"

  @Test("Verify that when creating a hard link to a symbolic link, '-L' option creates a hard link to the target of the symbolic link") func L_flag() async throws {
    let a = try tmpfile("A", "")
    let b = try tmpfile("B")
    let c = try tmpfile("C")
    defer { rm(a,b,c) }
    try await run(args: ["-s", a, b] )
    try await run(args: ["-L", b, c] )

    let aa = try? a.stat(followTargetSymlink: false)
    let bb = try? b.stat(followTargetSymlink: true)
    let bb2 = try? b.stat(followTargetSymlink: false)
    let cc = try? c.stat(followTargetSymlink: false)

    #expect(aa?.deviceID == cc?.deviceID && aa?.inode == cc?.inode)
    #expect(aa?.deviceID == bb?.deviceID && aa?.inode == bb?.inode && bb?.inode != bb2?.inode )
  }

  @Test("Verify that when creating a hard link to a symbolic link, '-P' option creates a hard link to the symbolic link itself") func P_flag() async throws {
    let a = try tmpfile("A2", "")
    let b = try tmpfile("B2")
    let c = try tmpfile("C2")
    defer { rm(a, b, c) }
    
    try await run(args: ["-s", a, b])
    try await run(args: ["-P", b, c])

    let bb = try? b.stat(followTargetSymlink: false)
    let cc = try? c.stat(followTargetSymlink: false)

    #expect(bb?.deviceID == cc?.deviceID && bb?.inode == cc?.inode)
  }

  @Test("Verify that if the target file already exists, '-f' option unlinks it so that link may occur") func f_flag() async throws {
    let a = try tmpfile("A3", "")
    let b = try tmpfile("B3", "")
    defer { rm(a,b) }
    try await run(args: ["-f", a, b])

    let aa = try? a.stat(followTargetSymlink: false)
    let bb = try? b.stat(followTargetSymlink: false)

    #expect(aa?.deviceID == bb?.deviceID && aa?.inode == bb?.inode)
  }

  @Test("Verify whether creating a hard link fails if the target file already exists") func target_exists_hard() async throws {
    let a = try tmpfile("A4", "")
    let b = try tmpfile("B4", "")
    let c = try tmpdir()
    defer { rm(a, b) }
    try await run(status: 1, error: /ln: B4: File exists/, args: a.relativeTo(c), b.relativeTo(c), cd: c)
  }

  @Test("Verify whether creating a symbolic link fails if the target file already exists") func target_exists_symbolic() async throws {
    let a = try tmpfile("A5", "")
    let b = try tmpfile("B5", "")
    let c = try tmpdir()
    defer { rm(a,b ) }
    try await run(status: 1, error: /ln: B5: File exists/, args: "-s", a.relativeTo(c), b.relativeTo(c), cd: c)
  }

  @Test("Verify that if the target directory is a symbolic link, 'shf' option prevents following the link") func shf_flag_dir() async throws {
    let a = try tmpdir("A6")
    let b = try tmpdir("B6")
    let c = try tmpfile("C6")
    defer { rm(a,b, c) }
    try await run(args: ["-s", a, c])
    try await run(args: ["-shf", b, c])

    let bb = try? b.stat(followTargetSymlink: false)
    let cc = try? c.stat(followTargetSymlink: true)

    #expect(cc?.deviceID == bb?.deviceID && cc?.inode == bb?.inode)
  }

  @Test("Verify that if the target directory is a symbolic link, 'snf' option prevents following the link") func snf_flag_dir() async throws {
    let a = try tmpdir("A7")
    let b = try tmpdir("B7")
    let c = try tmpfile("C7")
    defer { rm(a, b, c) }
    
    try await run(args: ["-s", a, c])
    try await run(args: ["-snf", b, c])

    let bb = try? b.stat(followTargetSymlink: false)
    let cc = try? c.stat(followTargetSymlink: true)

    #expect(cc?.deviceID == bb?.deviceID && cc?.inode == bb?.inode)
  }


  @Test("Verify that if the target file already exists and is a directory, then '-sF' option removes it so that the link may occur") func sF_flag() async throws {
    let a = try tmpdir("A8")
    let b = try tmpdir("B8")
    defer { rm(a, b) }
    
    try await run(args: ["-sF", a, b])

    let aa = try? a.stat(followTargetSymlink: false)
    let bb = try? b.stat(followTargetSymlink: true)

    #expect(aa?.deviceID == bb?.deviceID && aa?.inode == bb?.inode)
  }

  @Test("Verify that if the target file already exists, '-sf' option unlinks it and creates a symbolic link to the source file") func sf_flag() async throws {
    let a = try tmpfile("A9", "")
    let b = try tmpfile("B9", "")
    defer { rm(a, b) }
    try await run(args: ["-sf", a, b])

    let aa = try? a.stat(followTargetSymlink: false)
    let bb = try? b.stat(followTargetSymlink: true)

    #expect(aa?.deviceID == bb?.deviceID && aa?.inode == bb?.inode)
  }

  @Test("Verify that if the target file already exists and is a symlink, then '-sfF' option removes it so that the link may occur") func sfF_flag() async throws {
    let a = try tmpdir("A10")
    let b = try tmpdir("B10")
    let c = try tmpdir("C10")
    defer { rm(a, b, c) }
    try await run(args: ["-sF", a, c])

    let aa = try? a.stat(followTargetSymlink: false)
    let cc = try? c.stat(followTargetSymlink: true)
    #expect(aa?.deviceID == cc?.deviceID && aa?.inode == cc?.inode)

    try await run(args: ["-sfF", b, c])
    let bb = try? b.stat(followTargetSymlink: false)
    let cc2 = try? c.stat(followTargetSymlink: true)
    #expect(bb?.deviceID == cc2?.deviceID && bb?.inode == cc2?.inode)
  }

  @Test("Verify that '-s' option creates a symbolic link") func s_flag() async throws {
    let a = try tmpfile("A11", "")
    let b = try tmpfile("B11")
    defer { rm(a, b) }
    try await run(args: ["-s", a, b])

    let aa = try? a.stat(followTargetSymlink: false)
    let bb = try? b.stat(followTargetSymlink: true)
    #expect(aa?.deviceID == bb?.deviceID && aa?.inode == bb?.inode)
  }

  @Test("Verify that if the source file does not exist, '-s' option creates a broken symbolic link to the source file") func s_flag_broken() async throws {
    let a = try tmpfile("A12")
    let b = try tmpfile("B12")
    rm(a, b)
    defer { rm(a, b) }
    try await run(args: ["-s", a, b])

    //    let aa = try? FileMetadata(for: a.path, followSymlinks: false)
    let bb = try? b.stat(followTargetSymlink: false)
    let bb2 = try? b.stat(followTargetSymlink: true)
    //    #expect(aa?.deviceID == bb?.deviceID && aa?.inode == bb?.inode)

    #expect(bb2 == nil && bb?.type == .symbolicLink)
  }

  @Test("Verify that '-sw' option produces a warning if the source of a symbolic link does not currently exist") func sw_flag() async throws {
    let a = try tmpfile("A13")
    let b = try tmpfile("B13")
    rm(a, b)
    try await run(error: /ln: warning: .* inaccessible: No such file or directory/, args: ["-sw", a, b])

    let aa = try? a.stat(followTargetSymlink: false)
    let bb = try? b.stat(followTargetSymlink: true)
    #expect(aa?.deviceID == bb?.deviceID && aa?.inode == bb?.inode)
    rm(a, b)
  }

}

// Modernized by Robert M. Lefkowitz <r0ml@liberally.net> in 2025 using an LLM
// from a file containing the following notice:

/*
 Copyright (c) 2024 Dag-Erling Smørgrav

 SPDX-License-Identifier: BSD-2-Clause
*/

import ShellTesting
import CMigration

import Darwin

let jan1970 = 1711283696

extension timespec {
  var timeInterval : Int {
    return Int(tv_sec) // , * 1000_000_000 + tv_nsec)
  }
}

struct touchTest : ShellTest {
  var cmd = "touch"
  var suiteBundle = "file_cmds_touchTest"

  @Test("No arguments") func touch_none() async throws {
    try await run(status: 1, error: /usage: touch/, args: [] )
  }

  @Test("One argument") func touch_one() async throws {
    let foo = try tmpfile("foo1")
    defer { rm(foo) }
    try await run(args: [foo])
    #expect( foo.exists)
  }

  @Test("Multiple arguments") func touch_multiple() async throws {
    let foo = try tmpfile("foo")
    let bar = try tmpfile("bar")
    let baz = try tmpfile("baz")
    defer { rm(foo, bar, baz) }
    try await run(args: [foo, bar, baz])
    print("foo")
    #expect(foo.exists)
    #expect(bar.exists)
    #expect(baz.exists)
  }

  @Test("Absolute date / time") func absolute() async throws {
    let foo = try tmpfile("foo2")
    defer { rm(foo) }
    try await run(args: ["-t", "7001010101", foo], env: ["TZ":"UTC"])
    let m = try foo.stat()
    #expect(m.st_mtim.timeInterval == 3660)
    rm(foo)

    try await run(args: ["-t", "7001010101.01", foo], env: ["TZ":"UTC"])
    let m2 = try foo.stat()
    #expect(m2.st_mtim.timeInterval == 3661)
    rm(foo)

    try await run(args: ["-t", "196912312359", foo], env: ["TZ":"UTC"])
    let m3 = try foo.stat()
    #expect(m3.st_mtim.timeInterval == -60)
    rm(foo)

    try await run(args: ["-t", "196912312359.58", foo], env: ["TZ":"UTC"])
    let m4 = try foo.stat()
    #expect(m4.st_mtim.timeInterval == -2)
    rm(foo)

    // the time specification winds up being "-1" -- which registers as an error
    try await run(status: 1, error: /out of range/, args: ["-t", "196912312359.59", foo], env: ["TZ":"UTC"])
    rm(foo)

    try await run(args: ["-d1969-12-31T23:59:58", foo], env: ["TZ":"UTC"])
    let m6 = try foo.stat()
    #expect(m6.st_mtim.timeInterval == -2)
    rm(foo)

    try await run(args: ["-d1969-12-31 23:59:58", foo], env: ["TZ":"UTC"])
    let m7 = try foo.stat()
    #expect(m7.st_mtim.timeInterval == -2)
    rm(foo)

    try await run(args: ["-d1970-01-01T00:59:58", foo], env: ["TZ":"CET"])
    let m8 = try foo.stat()
    #expect(m8.st_mtim.timeInterval == -2)
    rm(foo)

    try await run(args: ["-d1970-01-01T00:59:58Z", foo], env: ["TZ":"CET"])
    let m9 = try foo.stat()
    #expect(m9.st_mtim.timeInterval == 3598)
    rm(foo)

    try await run(args: ["-d1969-12-31T23:59:59Z", foo], env: ["TZ":"CET"])
    rm(foo)
  }

  @Test("Relative date / time") func relative() async throws {
    let foo = try tmpfile("foo3")
    defer { rm(foo) }
    try await run(args: ["-t", "202403241234.56", foo], env: ["TZ":"UTC"])
    let m = try foo.stat()
    #expect(m.st_mtim.timeInterval == jan1970)

    try await run(args: ["-A", "-36", foo], env: ["TZ":"UTC"])
    let m2 = try foo.stat()
    #expect(m2.st_mtim.timeInterval == 1711283660)

    try await run(args: ["-A", "-0100", foo], env: ["TZ":"UTC"])
    let m3 = try foo.stat()
    #expect(m3.st_mtim.timeInterval == 1711283600)

    try await run(args: ["-A", "-010000", foo], env: ["TZ":"UTC"])
    let m4 = try foo.stat()
    #expect(m4.st_mtim.timeInterval == 1711280000)

    try await run(args: ["-A", "010136", foo], env: ["TZ":"UTC"])
    let m5 = try foo.stat()
    #expect(m5.st_mtim.timeInterval == 1711283696)
  }

  @Test("Copy time from another file") func copy() async throws {
    let foo = try tmpfile("foo4")
    let bar = try tmpfile("bar4")
    defer { rm(foo, bar) }
    try await run(args: ["-t", "202403241234.56", foo], env: ["TZ":"UTC"])
    let m = try foo.stat()
    #expect(m.st_mtim.timeInterval == jan1970)

    try await run(args: ["-t", "7001010000", bar], env: ["TZ":"UTC"])
    let m2 = try bar.stat()
    #expect(m2.st_mtim.timeInterval == 0)

    try await run(args: ["-r", foo, bar])
    let m3 = try foo.stat()
    #expect(m3.st_mtim.timeInterval == jan1970)
    rm(foo, bar)
  }

  @Test("Do not create file") func nocreate() async throws {
    let foo = try tmpfile("foo5")
    let bar = try tmpfile("bar5")
    defer { rm(foo, bar) }
    rm(foo, bar)
    try await run(args: ["-t", "202403241234.56", foo], env: ["TZ":"UTC"])
    let m = try foo.stat()
    #expect(m.st_mtim.timeInterval == jan1970)

    try await run(args: ["-c", "-t", "7001010000", foo, bar], env: ["TZ":"UTC"])
    let m2 = try foo.stat()
    #expect(m2.st_mtim.timeInterval == 0)
    #expect(!bar.exists)
    try await run(args: ["-c", bar])
    #expect(!bar.exists)
  }

  @Test("Verifying that touch(1)ing an existing file sets its modification time to be later than its creation time") func rdar70075417() async throws {
    let filename = try tmpfile("XXXX6", "")
    let c1 = try filename.stat().st_birthtim
    try await run(args: [filename])

    let m1 = try filename.stat().st_mtim
    // Compare with nanosecond precision: c1 and m1 can land in the same
    // second, and `timeInterval` (used elsewhere to check exact `-t` values)
    // truncates to whole seconds.
    let c1n = Int(c1.tv_sec) * 1_000_000_000 + c1.tv_nsec
    let m1n = Int(m1.tv_sec) * 1_000_000_000 + m1.tv_nsec
    #expect(m1n > c1n)

  }
}


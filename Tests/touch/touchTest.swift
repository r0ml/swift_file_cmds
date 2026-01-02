// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting
import CMigration

struct touchTest : ShellTest {
  var cmd = "touch"
  var suiteBundle = "touchTest"

  @Test("No arguments") func touch_none() async throws {
    try await run(status: 1, error: /usage: touch/, args: [] )
  }

  @Test("One argument") func touch_one() async throws {
    let foo = try tmpfile("foo1")
    try await run(args: [foo])
    #expect( FileManager.default.fileExists(atPath: foo.path ) )
    rm(foo)
  }

  @Test("Multiple arguments") func touch_multiple() async throws {
    let foo = try tmpfile("foo")
    let bar = try tmpfile("bar")
    let baz = try tmpfile("baz")
    try await run(args: [foo, bar, baz])
    print("foo")
    #expect(FileManager.default.fileExists(atPath: foo.path))
    #expect(FileManager.default.fileExists(atPath: bar.path))
    #expect(FileManager.default.fileExists(atPath: baz.path))
    rm(foo, bar, baz)
  }

  @Test("Absolute date / time") func absolute() async throws {
    let foo = try tmpfile("foo2")
    try await run(args: ["-t", "7001010101", foo], env: ["TZ":"UTC"])
    let m = try FileMetadata(for: foo.path)
    #expect(m.lastWrite.timeInterval == 3660)
    rm(foo)

    try await run(args: ["-t", "7001010101.01", foo], env: ["TZ":"UTC"])
    let m2 = try FileMetadata(for: foo.path)
    #expect(m2.lastWrite.timeInterval == 3661)
    rm(foo)

    try await run(args: ["-t", "196912312359", foo], env: ["TZ":"UTC"])
    let m3 = try FileMetadata(for: foo.path)
    #expect(m3.lastWrite.timeInterval == -60)
    rm(foo)

    try await run(args: ["-t", "196912312359.58", foo], env: ["TZ":"UTC"])
    let m4 = try FileMetadata(for: foo.path)
    #expect(m4.lastWrite.timeInterval == -2)
    rm(foo)

    // the time specification winds up being "-1" -- which registers as an error
    try await run(status: 1, error: /out of range/, args: ["-t", "196912312359.59", foo], env: ["TZ":"UTC"])
    rm(foo)

    try await run(args: ["-d1969-12-31T23:59:58", foo], env: ["TZ":"UTC"])
    let m6 = try FileMetadata(for: foo.path)
    #expect(m6.lastWrite.timeInterval == -2)
    rm(foo)

    try await run(args: ["-d1969-12-31 23:59:58", foo], env: ["TZ":"UTC"])
    let m7 = try FileMetadata(for: foo.path)
    #expect(m7.lastWrite.timeInterval == -2)
    rm(foo)

    try await run(args: ["-d1970-01-01T00:59:58", foo], env: ["TZ":"CET"])
    let m8 = try FileMetadata(for: foo.path)
    #expect(m8.lastWrite.timeInterval == -2)
    rm(foo)

    try await run(args: ["-d1970-01-01T00:59:58Z", foo], env: ["TZ":"CET"])
    let m9 = try FileMetadata(for: foo.path)
    #expect(m9.lastWrite.timeInterval == 3598)
    rm(foo)

    try await run(args: ["-d1969-12-31T23:59:59Z", foo], env: ["TZ":"CET"])
    rm(foo)
  }

  @Test("Relative date / time") func relative() async throws {
    let foo = try tmpfile("foo3")
    try await run(args: ["-t", "202403241234.56", foo], env: ["TZ":"UTC"])
    let m = try FileMetadata(for: foo.path)
    #expect(m.lastWrite.timeInterval == 1711283696)

    try await run(args: ["-A", "-36", foo], env: ["TZ":"UTC"])
    let m2 = try FileMetadata(for: foo.path)
    #expect(m2.lastWrite.timeInterval == 1711283660)

    try await run(args: ["-A", "-0100", foo], env: ["TZ":"UTC"])
    let m3 = try FileMetadata(for: foo.path)
    #expect(m3.lastWrite.timeInterval == 1711283600)

    try await run(args: ["-A", "-010000", foo], env: ["TZ":"UTC"])
    let m4 = try FileMetadata(for: foo.path)
    #expect(m4.lastWrite.timeInterval == 1711280000)

    try await run(args: ["-A", "010136", foo], env: ["TZ":"UTC"])
    let m5 = try FileMetadata(for: foo.path)
    #expect(m5.lastWrite.timeInterval == 1711283696)
    rm(foo)
  }

  @Test("Copy time from another file") func copy() async throws {
    let foo = try tmpfile("foo4")
    let bar = try tmpfile("bar4")
    try await run(args: ["-t", "202403241234.56", foo], env: ["TZ":"UTC"])
    let m = try FileMetadata(for: foo.path)
    #expect(m.lastWrite.timeInterval == 1711283696)

    try await run(args: ["-t", "7001010000", bar], env: ["TZ":"UTC"])
    let m2 = try FileMetadata(for: bar.path)
    #expect(m2.lastWrite.timeInterval == 0)

    try await run(args: ["-r", foo, bar])
    let m3 = try FileMetadata(for: bar.path)
    #expect(m3.lastWrite.timeInterval == 1711283696)
    rm(foo, bar)
  }

  @Test("Do not create file") func nocreate() async throws {
    let foo = try tmpfile("foo5")
    let bar = try tmpfile("bar5")
    rm(foo, bar)
    try await run(args: ["-t", "202403241234.56", foo], env: ["TZ":"UTC"])
    let m = try FileMetadata(for: foo.path)
    #expect(m.lastWrite.timeInterval == 1711283696)

    try await run(args: ["-c", "-t", "7001010000", foo, bar], env: ["TZ":"UTC"])
    let m2 = try FileMetadata(for: foo.path)
    #expect(m2.lastWrite.timeInterval == 0)
    #expect(!FileManager.default.fileExists(atPath: bar.path))
    try await run(args: ["-c", bar])
    #expect(!FileManager.default.fileExists(atPath: bar.path))

    rm(foo, bar)
  }

  @Test("Verifying that touch(1)ing an existing file sets its modification time to be later than its creation time") func rdar70075417() async throws {
    let filename = try tmpfile("XXXX6", "")
    let c1 = try FileMetadata(for: filename.path).created
    try await run(args: [filename])

    let m1 = try FileMetadata(for: filename.path).lastWrite
    #expect(m1.timeInterval > c1.timeInterval)

  }
}

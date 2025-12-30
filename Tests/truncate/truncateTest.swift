// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025

import ShellTesting

struct truncateTest : ShellTest {
  var cmd = "truncate"
  var suiteBundle = "truncateTest"

  func assertFileNotExists(_ path: String, file: StaticString = #file, line: UInt = #line) {
      let exists = FileManager.default.fileExists(atPath: path)
      #expect(!exists, "File \(path) should not exist")
  }

  @Test("Verify that truncate exits >0 when passed an invalid command line option") func illegal_option() async throws {
    let k = try tmpfile("output3.txt")
    rm(k)
    try await run(status: 1, error: /truncate: illegal option -- 7/, args: ["-7", "-s0", k] )
    assertFileNotExists(k.path)
  }


  @Test("Verifies that truncate exits >0 when passed an invalid power of two convention") func illegal_size() async throws {
    let k = try tmpfile("output4.txt")
    try await run(status: 1, error: /truncate: invalid size argument `\+1L'/, args: ["-s+1L", k] )
    assertFileNotExists(k.path)
    rm(k)
  }


  @Test("Verifies that truncate exits >0 when passed a size that is INT64_MAX < size <= UINT64_MAX") func too_large_size() async throws {
    let k = try tmpfile("output5.txt")
    try await run(status: 1, error: /truncate: invalid size argument \`8388608t'/, args: ["-s8388608t", k] )
    assertFileNotExists(k.path)
    rm(k)
  }

  @Test("Verifies that -c prevents creation of new files") func opt_c() async throws {
    try await run(status: 0, args: ["-c", "-s", "0", "doesnotexist.txt"] )
    assertFileNotExists("doesnotexist.txt")
    let k = try tmpfile("reference", "")
    try await run(args: ["-c", "-r", k, "doesnotexist.txt"] )
    assertFileNotExists("doesnotexist.txt")
    let k2 = try tmpfile("exists.txt", "")
    try await run(args: ["-c", "-s1", k2] )
    let j = try fileContents(k2.path)
    #expect(j.count == 1)
  }

  @Test("Verifies that truncate command line flags -s and -r cannot be specified together") func opt_rs() async throws {
    let k = try tmpfile("afile")
    try await run(status: 1, error: /usage: truncate/, args: ["-s0", "-r", k, k])
  }


  @Test("Verifies that truncate needs a list of files on the command line") func no_files() async throws {
    try await run(status: 1, error: /usage: truncate/, args: ["-s1"])
  }

  @Test("Verifies that truncate detects a non-existent reference file") func bad_refer() async throws {
    let k = try tmpfile("afile")
    rm(k)
    try await run(status: 1, error: /truncate: afile: No such file or directory/, args: ["-r", k, k])
  }

  @Test("Verifies that truncate reports an error during truncation") func bad_truncate() async throws {
    let k = try tmpfile("exists.txt", "")
    let fa = [FileAttributeKey.posixPermissions: NSNumber(value: 0o444)]
    try FileManager.default.setAttributes(fa, ofItemAtPath: k.path  )
    try await run(status: 1, error: /truncate: *exists.txt: Permission denied/, args: ["-s1", k])
  }

  @Test("Verifies truncate can make and grow a new 1m file") func new_absolute_grow() async throws {
    let k = try tmpfile("output.txt")
    try await run(args: ["-s1k", k])
    let j = try fileContents(k.path)
    #expect(j.count == 1024, "expected file size of 1k")
    try await run(args: ["-s1M", k])
    // let jj = try fileContents(k.path)
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 1048576, "expected file size of 1M")
    rm(k)
  }

  @Test("Verifies that truncate can make and shrink a new 1m file") func new_absolute_shrin() async throws {
    let k = try tmpfile("output2.txt")
    try await run(args: ["-s1M", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 1048576, "expected file size of 1M")
    try await run(args: ["-s1k", k])
    let jk = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jk == 1024, "expected file size of 1k")
    rm(k)
  }

  @Test("Verifies truncate can make and grow a new 1m file using relative sizes") func new_relative_grow() async throws {
    let k = try tmpfile("output7.txt")
    try await run(args: ["-s+1k", k])
    let jk = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jk == 1024, "expected file size of 1k")
    try await run(args: ["-s+1047552", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 1048576, "expected file size of 1m")
    rm(k)
  }

  @Test("Verifies truncate can make and shrink a new 1m file using relative sizes") func new_relative_shrink() async throws {
    let k = try tmpfile("output8.txt")
    try await run(args: ["-s+1049600", k])
    let jk = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jk == 1049600, "expected file size of 1m")
    try await run(args: ["-s-1M", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 1024, "expected file size of 1k")
    rm(k)
  }

  @Test("Verifies truncate handles open failures correctly in a list of files") func cannot_open() async throws {
    let before = try tmpfile("before", "")
    let z = try tmpfile("0000", "")
    let after = try tmpfile("after", "")
    let fa = [FileAttributeKey.posixPermissions: NSNumber(value: 0o0000)]
    try FileManager.default.setAttributes(fa, ofItemAtPath: z.path  )

    try await run(status: 1, args: ["-c", "-s1k", before, z, after])
    let jc = try FileManager.default.attributesOfItem(atPath: before.path)[FileAttributeKey.size] as? Int
    #expect(jc == 1024, "expected file size of 1k")
    let jd = try FileManager.default.attributesOfItem(atPath: after.path)[FileAttributeKey.size] as? Int
    #expect(jd == 1024, "expected file size of 1k")
    let je = try FileManager.default.attributesOfItem(atPath: z.path)[FileAttributeKey.size] as? Int
    #expect(je == 0, "expected file size of zero")
    rm(before, z, after)
  }

  @Test("Verifies that truncate can use a reference file") func reference() async throws {
    let k = try tmpfile("reference2", "123\n")
    let j = try tmpfile("afile2")
    try await run(args: ["-r", k, j])
    let jc = try FileManager.default.attributesOfItem(atPath: j.path)[FileAttributeKey.size] as? Int
    #expect(jc == 4, "new file should also be 4 bytes")
    rm(j, k)
  }

  @Test("Verifies truncate can make and grow zero byte file") func new_zero() async throws {
    let k = try tmpfile("output9.txt")
    try await run(args: ["-s0", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 0, "expected file size of zero")
    try await run(args: ["-s+0", k])
    let jd = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jd == 0, "expected file size of zero")
    rm(k)
  }

  @Test("Verifies truncate treats negative sizes as zero") func negative() async throws {
    let k = try tmpfile("afile3.txt", "abcd\n")
    try await run(args: ["-s-100", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 0, "new file should now be zero bytes")
    rm(k)
  }

  @Test("Verifies truncate round up") func roundup() async throws {
    let k = try tmpfile("afile4.txt", "abcd\n")
    try await run(args: ["-s%100", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 100, "new file should now be 100 bytes")
    rm(k)
  }

  @Test("Verifies truncate round down") func rounddown() async throws {
    let k = try tmpfile("afile5.txt", "abcd\n")
    try await run(args: ["-s/2", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 4, "new file should now be 4 bytes")
    rm(k)
  }

  @Test("Verifies truncate round down to zero") func rounddown_zero() async throws {
    let k = try tmpfile("afile6.txt", "abcd\n")
    try await run(args: ["-s/10", k])
    let jc = try FileManager.default.attributesOfItem(atPath: k.path)[FileAttributeKey.size] as? Int
    #expect(jc == 0, "new file should now be 0 bytes")
    rm(k)
  }
}


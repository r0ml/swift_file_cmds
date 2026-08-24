// Modernized by Robert "r0ml" Lefkowitz <r0ml@liberally.net> in 2025
// from a file containing the following notice:

/*
 # Copyright (c) 2017 Dell EMC
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
import Darwin

@Suite("chmodTest", .serialized) struct chmodTest : ShellTest {
  let cmd = "chmod"
  let suiteBundle = "file_cmds_chmodTest"
  
  /*
   get_filesystem()
   {
   local mountpoint=$1
   
   df -T $mountpoint | tail -n 1 | cut -wf 2
   }
   */
  
  @Test("Verify that setting modes recursively via -R doesn't affect symlinks specified via the arguments when -H is specified")
  func RH_flag() async throws {
    
    //   atf_check mkdir -m 0777 -p A/B
    //   atf_check ln -s B A/C
    
    // tmpdir() always creates directories as 0700; explicitly set the
    // permissions "mkdir -m 0777 -p A/B" would produce: the leaf directory
    // gets the exact requested mode, ancestors get the umask-adjusted default.
    let ab = try tmpdir("A_RH/B")
    let ac = try tmpfile("A_RH/C")
    try ac.createSymbolicLink(to: "B")
    let a = try tmpdir("A_RH")
    chmod(a.string, 0o755)
    chmod(ab.string, 0o777)

    defer { rm(ab, ac, a) }

    try await run(output: "",args: "-h", "0777", ac)
    
    //   atf_check chmod -h 0777 A/C
    let x = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil)
    let res = try x.string(encoded: .utf8)
    #expect(res == "40755\n40777\n120777\n")  
    
    //   atf_check -o inline:'40755\n40777\n120777\n' stat -f '%p' A A/B A/C
    try await run(output: "", args: "-RH", "0700", a)
    //   atf_check chmod -RH 0700 A
    let y = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil) 
    let res2 = try y.string(encoded: .utf8)
    #expect(res2 == "40700\n40700\n120700\n")
    
    
    //   atf_check -o inline:'40700\n40700\n120700\n' stat -f '%p' A A/B A/C
    try await run(output: "", args: "-RH", "0600", ac)
    //   atf_check chmod -RH 0600 A/C
    //   atf_check -o inline:'40700\n40600\n120700\n' stat -f '%p' A A/B A/C
    let z = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil) 
    let res3 = try z.string(encoded: .utf8)
    #expect(res3 == "40700\n40600\n120700\n")
    
  }
  
  
  @Test("Verify that setting modes recursively via -R doesn't affect symlinks specified via the arguments when -L is specified")
  func RL_flag() async throws {
    let ab = try tmpdir("A_RL/B")
    let ac = try tmpfile("A_RL/C")
    try ac.createSymbolicLink(to: "B")
    let a = try tmpdir("A_RL")
    chmod(a.string, 0o755)
    chmod(ab.string, 0o777)
    
    defer { rm(ab, ac, a) }
    
    
    //   atf_check mkdir -m 0777 -p A/B
    //   atf_check ln -s B A/C
    
    try await run(output: "", args: "-h", "0777", ac)
    
    //   atf_check chmod -h 0777 A/C
    let x = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil)
    let res = try x.string(encoded: .utf8)
    #expect(res == "40755\n40777\n120777\n")  
    
    //   atf_check -o inline:'40755\n40777\n120777\n' stat -f '%p' A A/B A/C
    
    try await run(output: "", args: "-RL", "0700", a)
    let y = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil)
    let res2 = try y.string(encoded: .utf8)
    #expect(res2 == "40700\n40700\n120777\n")  
    
    //   atf_check chmod -RL 0700 A
    //   atf_check -o inline:'40700\n40700\n120777\n' stat -f '%p' A A/B A/C
    
    try await run(output: "", args: "-RL", "0600", ac)
    //   atf_check chmod -RL 0600 A/C
    let z = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil)
    let res3 = try z.string(encoded: .utf8)
    #expect(res3 == "40700\n40600\n120777\n")  
    //   atf_check -o inline:'40700\n40600\n120777\n' stat -f '%p' A A/B A/C
  }
  
  @Test("Verify that setting modes recursively via -R doesn't affect symlinks specified via the arguments when -P is specified")
  func RP_flag() async throws {
    let ab = try tmpdir("A_RP/B")
    let ac = try tmpfile("A_RP/C")
    try ac.createSymbolicLink(to: "B")
    let a = try tmpdir("A_RP")
    chmod(a.string, 0o755)
    chmod(ab.string, 0o777)
    defer { rm(a) }

    try await run(output:"", args: "-h", "0777", ac)
//   atf_check chmod -h 0777 A/C
    let x = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil)
    let res = try x.string(encoded: .utf8)
    #expect(res == "40755\n40777\n120777\n")  

//   atf_check -o inline:'40755\n40777\n120777\n' stat -f '%p' A A/B A/C
//   atf_check chmod -RP 0700 A
    try await run(output:"", args: "-RP", "0700", a)
//   atf_check chmod -h 0777 A/C
    let y = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil)
    let res2 = try y.string(encoded: .utf8)
    #expect(res2 == "40700\n40700\n120700\n")
//   atf_check -o inline:'40700\n40700\n120700\n' stat -f '%p' A A/B A/C
    
    try await run(output:"", args: "-RP", "0600", ac)
    let z = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", a, ab, ac, output: nil)
    let res3 = try z.string(encoded: .utf8)
    #expect(res3 == "40700\n40700\n120600\n")  
    //   atf_check chmod -RP 0600 A/C
//   atf_check -o inline:'40700\n40700\n120600\n' stat -f '%p' A A/B A/C
   }

  @Test("Verify that setting a mode for a file with -f doesn't emit an error message/exit with a non-zero code")
  func f_flag() async throws {
    let foo = try tmpfile("foo", "")
    let bar = try tmpfile("bar", "")
//   atf_check truncate -s 0 foo bar
    defer { rm(foo, bar) }
    
    try await run(output: "", args: "0750", foo, bar)
//   atf_check chmod 0750 foo bar
    // FIXME: do I need to do this?
//   case "$(get_filesystem .)" in
//   zfs)
//   atf_expect_fail "ZFS doesn't support UF_IMMUTABLE; returns EPERM - bug 221189"
//   ;;
//   esac
    
   let (st, _) = strtofflags("uchg")!
    let kkk = Darwin.chflags(foo.string, st.rawValue)
    print(kkk)
    defer { Darwin.chflags(foo.string, 0) }
//   atf_check chflags uchg foo
//   atf_check -e not-empty -s not-exit:0

    try await run(status: 1, args: "0700", foo, bar)
    
    let z = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", foo, bar, output: nil)
    let res3 = try z.string(encoded: .utf8)
    #expect(res3 == "100750\n100700\n")
//   atf_check -o inline:'100750\n100700\n' stat -f '%p' foo bar
    
    try await run(status: 0, args: "-f", "0600", foo, bar)
//   atf_check -s exit:0 chmod -f 0600 foo bar
    let y = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", foo, bar, output: nil)
    let res2 = try y.string(encoded: .utf8)
    #expect(res2 == "100750\n100600\n")
//   atf_check -o inline:'100750\n100600\n' stat -f '%p' foo bar
   }
   

  @Test("testing -h flag") func h_flag() async throws {
    let foo = try tmpfile("foo", "")
    Darwin.chmod( foo.string, 0o0600)
    defer { rm(foo) }
    
    let z = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", foo, output: nil)
    let res3 = try z.string(encoded: .utf8)
    #expect(res3 == "100600\n")

//    atf_check -o inline:'100600\n' stat -f '%p' foo
 

    let k = Darwin.umask(0o0077)
    let bar = try tmpfile("bar")
    rm(bar)
    try bar.createSymbolicLink(to: "foo")
    defer { rm(bar) }
    
//   atf_check ln -s foo bar
    #expect( try foo.stat().permissions.rawValue == 0o100600)
    let p = try bar.stat(followTargetSymlink: false).permissions.rawValue
    #expect( p == 0o120700)

//    let y = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", foo, bar, output: nil)
//    let res2 = try y.string(encoded: .utf8)
//    #expect(res2 == "100600\n120700\n")
 
//   atf_check -o inline:'100600\n120700\n' stat -f '%p' foo bar

    try await run(output: "", args: "-h", "0500", bar)
//    atf_check chmod -h 0500 bar
    let x = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", foo, bar, output: nil)
    let res = try x.string(encoded: .utf8)
    #expect(res == "100600\n120500\n")
//   atf_check -o inline:'100600\n120500\n' stat -f '%p' foo bar
    
    try await run(output: "", args: "0660", bar)
//   atf_check chmod 0660 bar
    let q = try await DarwinProcess().run("/usr/bin/stat", args: "-f", "%p", foo, bar, output: nil)
    let res4 = try q.string(encoded: .utf8)
    #expect(res4 == "100660\n120500\n")
  
//   atf_check -o inline:'100660\n120500\n' stat -f '%p' foo bar
  }
  
  @Test("Verify that setting a mode with -v emits the file when doesn't emit an error message/exit with a non-zero code")
  func v_flag() async throws {
    
    let foo = try tmpfile("foo", "")
    let bar = try tmpfile("bar", "")
    let d = try tmpdir()
    
    defer { rm(foo, bar) }
    
    Darwin.chmod(foo.string, 0o0600)
    Darwin.chmod(bar.string, 0o0750)
//   atf_check truncate -s 0 foo bar
//   atf_check chmod 0600 foo
//   atf_check chmod 0750 bar
    // Do I need this?
//   case "$(get_filesystem .)" in
//   zfs)
//   atf_expect_fail "ZFS updates mode for foo unnecessarily - bug 221188"
//   ;;
//   esac
    try await run(output: "bar\n", args: "-v", "0600", foo.relativeTo(d), bar.relativeTo(d), cd: d)    
//   atf_check -o 'inline:bar\n' chmod -v 0600 foo bar
    try await run(output: "", args: "-v", "0600", foo.relativeTo(d), bar.relativeTo(d), cd: d)
//   atf_check chmod -v 0600 foo bar
    
    let outp = """
foo: 0100600 [-rw------- ] -> 0100700 [-rwx------ ]
bar: 0100600 [-rw------- ] -> 0100700 [-rwx------ ]

"""
    
//   for f in foo bar; do
//   echo "$f: 0100600 [-rw------- ] -> 0100700 [-rwx------ ]";
//   done > output.txt
    try await run(output: outp, args: "-vv", "0700", foo.relativeTo(d), bar.relativeTo(d), cd: d)
//   atf_check -o file:output.txt chmod -vv 0700 foo bar
    try await run(output: "", args: "-vv", "0700", foo.relativeTo(d), bar.relativeTo(d), cd: d)
//   atf_check chmod -vv 0700 foo bar
   }
   
}

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
    try await run(status: 1, error: /truncate: illegal option -- 7/, args: ["-7", "-s0", "output.txt"] )
    assertFileNotExists("output.txt")
  }


  @Test("Verifies that truncate exits >0 when passed an invalid power of two convention") func illegal_size() async throws {
    try await run(status: 1, error: /truncate: invalid size argument `\+1L'/, args: ["-s+1L", "output.txt"] )
    assertFileNotExists("output.txt")
  }


  @Test("Verifies that truncate exits >0 when passed a size that is INT64_MAX < size <= UINT64_MAX") func too_large_size() async throws {
    try await run(status: 1, error: /truncate: invalid size argument \`8388608t'/, args: ["-s8388608t", "output.txt"] )
    assertFileNotExists("output.txt")
  }

  @Test("Verifies that -c prevents creation of new files") func opt_c() async throws {
    try await run(status: 0, args: ["-c", "-s", "0", "doesnotexist.txt"] )
    assertFileNotExists("doesnotexist.txt")
    let k = try tmpfile("reference", "")
    try await run(status: 0, args: ["-c", "-r", k, "doesnotexist.txt"] )
    assertFileNotExists("doesnotexist.txt")
  }




  /*
   > exists.txt
   atf_check -e file:stderr.txt truncate -c -s1 exists.txt
   [ -s exists.txt ] || atf_fail "exists.txt be larger than zero bytes"
   }

   atf_test_case opt_rs
   opt_rs_head()
   {
   atf_set "descr" "Verifies that truncate command line flags" \
   "-s and -r cannot be specifed together"
   }
   opt_rs_body()
   {
   create_stderr_usage_file

   # Force an error due to the use of both -s and -r.
   > afile
   atf_check -s not-exit:0 -e file:stderr.txt truncate -s0 -r afile afile
   }

   atf_test_case no_files
   no_files_head()
   {
   atf_set "descr" "Verifies that truncate needs a list of files on" \
   "the command line"
   }
   no_files_body()
   {
   create_stderr_usage_file

   # A list of files must be present on the command line.
   atf_check -s not-exit:0 -e file:stderr.txt truncate -s1
   }

   atf_test_case bad_refer
   bad_refer_head()
   {
   atf_set "descr" "Verifies that truncate detects a non-existent" \
   "reference file"
   }
   bad_refer_body()
   {
   create_stderr_file "truncate: afile: No such file or directory"

   # The reference file must exist before you try to use it.
   atf_check -s not-exit:0 -e file:stderr.txt truncate -r afile afile
   [ ! -e afile ] || atf_fail "afile should not exist"
   }

   atf_test_case bad_truncate
   bad_truncate_head()
   {
   atf_set "descr" "Verifies that truncate reports an error during" \
   "truncation"
   atf_set "require.user" "unprivileged"
   }
   bad_truncate_body()
   {
   create_stderr_file "truncate: exists.txt: Permission denied"

   # Trying to get the ftruncate() call to return -1.
   > exists.txt
   atf_check chmod 444 exists.txt

   atf_check -s not-exit:0 -e file:stderr.txt truncate -s1 exists.txt
   }

   atf_test_case new_absolute_grow
   new_absolute_grow_head()
   {
   atf_set "descr" "Verifies truncate can make and grow a new 1m file"
   }
   new_absolute_grow_body()
   {
   create_stderr_file

   # Create a new file and grow it to 1024 bytes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s1k output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1024 ] || atf_fail "expected file size of 1k"

   create_stderr_file

   # Grow the existing file to 1M.  We are using absolute sizes.
   atf_check -s exit:0 -e file:stderr.txt truncate -c -s1M output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1048576 ] || atf_fail "expected file size of 1m"
   }

   atf_test_case new_absolute_shrink
   new_absolute_shrink_head()
   {
   atf_set "descr" "Verifies that truncate can make and" \
   "shrink a new 1m file"
   }
   new_absolute_shrink_body()
   {
   create_stderr_file

   # Create a new file and grow it to 1048576 bytes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s1M output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1048576 ] || atf_fail "expected file size of 1m"

   create_stderr_file

   # Shrink the existing file to 1k.  We are using absolute sizes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s1k output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1024 ] || atf_fail "expected file size of 1k"
   }

   atf_test_case new_relative_grow
   new_relative_grow_head()
   {
   atf_set "descr" "Verifies truncate can make and grow a new 1m file" \
   "using relative sizes"
   }
   new_relative_grow_body()
   {
   create_stderr_file

   # Create a new file and grow it to 1024 bytes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s+1k output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1024 ] || atf_fail "expected file size of 1k"

   create_stderr_file

   # Grow the existing file to 1M.  We are using relative sizes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s+1047552 output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1048576 ] || atf_fail "expected file size of 1m"
   }

   atf_test_case new_relative_shrink
   new_relative_shrink_head()
   {
   atf_set "descr" "Verifies truncate can make and shrink a new 1m file" \
   "using relative sizes"
   }
   new_relative_shrink_body()
   {
   create_stderr_file

   # Create a new file and grow it to 1049600 bytes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s+1049600 output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1049600 ] || atf_fail "expected file size of 1m"

   create_stderr_file

   # Shrink the existing file to 1k.  We are using relative sizes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s-1M output.txt
   atf_check -s exit:1 cmp -s output.txt /dev/zero
   eval $(stat -s output.txt)
   [ ${st_size} -eq 1024 ] || atf_fail "expected file size of 1k"
   }

   atf_test_case cannot_open
   cannot_open_head()
   {
   atf_set "descr" "Verifies truncate handles open failures correctly" \
   "in a list of files"
   atf_set "require.user" "unprivileged"
   }
   cannot_open_body()
   {
   # Create three files -- the middle file cannot allow writes.
   > before
   > 0000
   > after
   atf_check chmod 0000 0000

   create_stderr_file "truncate: 0000: Permission denied"

   # Create a new file and grow it to 1024 bytes.
   atf_check -s not-exit:0 -e file:stderr.txt \
   truncate -c -s1k before 0000 after
   eval $(stat -s before)
   [ ${st_size} -eq 1024 ] || atf_fail "expected file size of 1k"
   eval $(stat -s after)
   [ ${st_size} -eq 1024 ] || atf_fail "expected file size of 1k"
   eval $(stat -s 0000)
   [ ${st_size} -eq 0 ] || atf_fail "expected file size of zero"
   }

   atf_test_case reference
   reference_head()
   {
   atf_set "descr" "Verifies that truncate can use a reference file"
   }
   reference_body()
   {
   # Create a 4 byte reference file.
   printf "123\n" > reference
   eval $(stat -s reference)
   [ ${st_size} -eq 4 ] || atf_fail "reference file should be 4 bytes"

   create_stderr_file

   # Create a new file and grow it to 4 bytes.
   atf_check -e file:stderr.txt truncate -r reference afile
   eval $(stat -s afile)
   [ ${st_size} -eq 4 ] || atf_fail "new file should also be 4 bytes"
   }

   atf_test_case new_zero
   new_zero_head()
   {
   atf_set "descr" "Verifies truncate can make and grow zero byte file"
   }
   new_zero_body()
   {
   create_stderr_file

   # Create a new file and grow it to zero bytes.
   atf_check -s exit:0 -e file:stderr.txt truncate -s0 output.txt
   eval $(stat -s output.txt)
   [ ${st_size} -eq 0 ] || atf_fail "expected file size of zero"

   # Pretend to grow the file.
   atf_check -s exit:0 -e file:stderr.txt truncate -s+0 output.txt
   eval $(stat -s output.txt)
   [ ${st_size} -eq 0 ] || atf_fail "expected file size of zero"
   }

   atf_test_case negative
   negative_head()
   {
   atf_set "descr" "Verifies truncate treats negative sizes as zero"
   }
   negative_body()
   {
   # Create a 5 byte file.
   printf "abcd\n" > afile
   eval $(stat -s afile)
   [ ${st_size} -eq 5 ] || atf_fail "afile file should be 5 bytes"

   create_stderr_file

   # Create a new file and do a 100 byte negative relative shrink.
   atf_check -e file:stderr.txt truncate -s-100 afile
   eval $(stat -s afile)
   [ ${st_size} -eq 0 ] || atf_fail "new file should now be zero bytes"
   }

   atf_test_case roundup
   roundup_head()
   {
   atf_set "descr" "Verifies truncate round up"
   }
   roundup_body()
   {
   # Create a 5 byte file.
   printf "abcd\n" > afile
   eval $(stat -s afile)
   [ ${st_size} -eq 5 ] || atf_fail "afile file should be 5 bytes"

   create_stderr_file

   # Create a new file and do a 100 byte roundup.
   atf_check -e file:stderr.txt truncate -s%100 afile
   eval $(stat -s afile)
   [ ${st_size} -eq 100 ] || atf_fail "new file should now be 100 bytes"
   }

   atf_test_case rounddown
   rounddown_head()
   {
   atf_set "descr" "Verifies truncate round down"
   }
   rounddown_body()
   {
   # Create a 5 byte file.
   printf "abcd\n" > afile
   eval $(stat -s afile)
   [ ${st_size} -eq 5 ] || atf_fail "afile file should be 5 bytes"

   create_stderr_file

   # Create a new file and do a 2 byte roundup.
   atf_check -e file:stderr.txt truncate -s/2 afile
   eval $(stat -s afile)
   [ ${st_size} -eq 4 ] || atf_fail "new file should now be 4 bytes"
   }

   atf_test_case rounddown_zero
   rounddown_zero_head()
   {
   atf_set "descr" "Verifies truncate round down to zero"
   }
   rounddown_zero_body()
   {
   # Create a 5 byte file.
   printf "abcd\n" > afile
   eval $(stat -s afile)
   [ ${st_size} -eq 5 ] || atf_fail "afile file should be 5 bytes"

   create_stderr_file

   # Create a new file and do a 10 byte roundup.
   atf_check -e file:stderr.txt truncate -s/10 afile
   eval $(stat -s afile)
   [ ${st_size} -eq 0 ] || atf_fail "new file should now be 0 bytes"
   }

   atf_init_test_cases()
   {
   atf_add_test_case opt_c
   atf_add_test_case opt_rs
   atf_add_test_case no_files
   atf_add_test_case bad_refer
   atf_add_test_case bad_truncate
   atf_add_test_case cannot_open
   atf_add_test_case new_absolute_grow
   atf_add_test_case new_absolute_shrink
   atf_add_test_case new_relative_grow
   atf_add_test_case new_relative_shrink
   atf_add_test_case reference
   atf_add_test_case new_zero
   atf_add_test_case negative
   atf_add_test_case roundup
   atf_add_test_case rounddown
   atf_add_test_case rounddown_zero
   }

   */
}


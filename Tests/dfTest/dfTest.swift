// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2025 using an LLM
// from a file containing the notice:

/*
 # Copyright (c) 2023 Apple Inc. All rights reserved.
 #
 # @APPLE_LICENSE_HEADER_START@
 #
 # This file contains Original Code and/or Modifications of
 # Original Code as defined in and that are subject to the Apple Public
 # Source License Version 1.0 (the 'License').  You may not use this file
 # except in compliance with the License.  Please obtain a copy of the
 # License at http://www.apple.com/publicsource and read it before using
 # this file.
 #
 # The Original Code and all software distributed under the License are
 # distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 # EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 # INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 # FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT.  Please see the
 # License for the specific language governing rights and limitations
 # under the License."
 #
 */

import ShellTesting

@Suite("dfTest") struct dfTest : ShellTest {
  let cmd = "df"
  let suiteBundle = "file_cmds_dfTest"
  
  @Test(.disabled("Not yet implemented")) func notYetImplemented() {
    Issue.record("Tests not yet implemented")
  }
}
/*
 atf_test_case df_1000 cleanup
 df_1000_head()
 {
   atf_set "descr" "Unit suffix corner case (rdar://31071849)"
   atf_set "require.user" "root"
 }
 df_1000_body()
 {
   mkdir $PWD/mnt
   atf_check mount_tmpfs -s 1000000000 $PWD/mnt
   atf_check -o match:"^tmpfs[[:space:]]+1000M" df -H $PWD/mnt
 }
 df_1000_cleanup()
 {
   umount $PWD/mnt
 }

 atf_init_test_cases()
 {
   atf_add_test_case df_1000
 }

 */

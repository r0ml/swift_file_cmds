// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026

import Darwin

extension gzip {

  /* maybe print a warning */
  func maybe_warn(_ fmt : String, _ ap : CVarArg...) {
    if !options.qflag {
      withVaList(ap) {
        vwarn(fmt, $0)
      }
    }
    if r.exit_value == 0 {
      r.exit_value = 1
    }
  }

  /* ... without an errno. */
  func maybe_warnx(_ fmt : String, _ ap : CVarArg...) {

    if !options.qflag {
      withVaList(ap) {
        vwarnx(fmt, $0)
      }
    }
    if r.exit_value == 0 {
      r.exit_value = 1
    }
  }

  /* maybe print an error */
  func maybe_err(_ fmt : String, _ ap : CVarArg...) {
    withVaList(ap) {
      if !options.qflag {
        vwarn(fmt, $0);
      }
    }
    exit(2)
  }

  /* ... without an errno. */
  func maybe_errx(_ fmt : String, _ ap : CVarArg...) {
    withVaList(ap) {
      if !options.qflag {
        vwarnx(fmt, $0);
      }
    }
    exit(2)
  }
}

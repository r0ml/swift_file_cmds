// Copyright (c) 1868 Charles Babbage
// Modernized by Robert "r0ml" Lefkowitz <code@liberally.net> in 2026

import libxo

@discardableResult func xo_attr(_ name : String, _ format : String, _ args : CVarArg...) -> xo_ssize_t {
  withVaList(args) { a in
      xo_attr_hv(nil, name, format, a)
  }
}

func xo_warn(_ fmt : String, _ args : [CVarArg]) {
  let code = errno
  withVaList( args ) {
    //    va_start(vap, fmt);
    xo_warn_hcv(nil, code, 0, fmt, $0);
    //    va_end(vap);
  }
}

func xo_warn(_ fmt : String, _ args : CVarArg...) {
  let code = errno
  withVaList( args ) {
    //    va_start(vap, fmt);
    xo_warn_hcv(nil, code, 0, fmt, $0)
    //    va_end(vap);
  }
}

func xo_warnx (_ fmt : String, _ args : [CVarArg]) {
  withVaList(args) {
    xo_warn_hcv(nil, -1, 0, fmt, $0)
  }
}

func xo_warnx (_ fmt : String, _ args : CVarArg...) {
  withVaList(args) {
    xo_warn_hcv(nil, -1, 0, fmt, $0)
  }
}

func xo_errx(_ eval : Int32, _ fmt : String, _ args : CVarArg...) {
  xo_warnx(fmt, args)
  exit(eval)
}


func xo_err(_ code : Int32, _ fmt : String, _ args : CVarArg...) {
  errno = code
  xo_warn(fmt, args)
  xo_finish()
  exit(1)
}


func xo_err(_ fmt : String, _ args : CVarArg...) {
  xo_warn(fmt, args)
  xo_finish()
  exit(1)
}

@discardableResult func xo_emit(_ fmt : String, _ args : CVarArg...) -> Int {
  return xo_emit_hv(nil, fmt, args)
}

@discardableResult
func xo_emit_hv(_ xop : OpaquePointer?, _ fmt : String, _ args : [CVarArg]) -> Int {
  return withVaList( args ) { args in
    xo_emit_hv(xop, fmt, args)
  }
}

@discardableResult
func xo_emit_hv(_ xop : OpaquePointer?, _ fmt : String, _ args : CVarArg...) -> Int {
  return withVaList( args ) { args in
    xo_emit_hv(xop, fmt, args)
  }
}

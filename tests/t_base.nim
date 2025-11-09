import std/[unittest, math], fixedpoint
include util

template defineTests(build: untyped, p: static Natural) =
  suite "Fixed point basics for " & $typeof(build(4, p)):
    test "toInt":
      check build(1, p).toInt == 1
      check build(1.5, p).toInt == 1
      check build(2, p).toInt == 2

    test "toFloat":
      check build(1, p) == 1.0
      check build(1.7, p) == 1.7

    test "toString":
      check $build(10, p) == "10.0"

    test "precision":
      check build(10, p).precision == p

    test "Converting to fp64":
      check build(10, p).toFp64.toInt() == 10'i64

    test "Converting to fp32":
      check build(10, p).toFp32.toInt() == 10'i32

defineTests(fp32, 4)
defineTests(fp32, 8)
defineTests(fp32, 16)

defineTests(fp64, 4)
defineTests(fp64, 8)
defineTests(fp64, 16)

const FPVecPrecision = 6
type FixedPointAlias = FPInt32[FPVecPrecision]

suite "Fixed point types":
  test "Precision of aliases":
    check FixedPointAlias(1000).precision == 6

  test "High":
    check high(FPInt32[4]) is FPInt32[4]
    check high(FPInt32[4]) == 134217727.9375
    check high(FPInt32[8]) == 8388608
    check high(FPInt32[16]) == 32768

    check high(FPInt64[4]) is FPInt64[4]
    check high(FPInt64[4]) == 5.764607523034235e+17
    check high(FPInt64[8]) == 36028797018963970.0
    check high(FPInt64[16]) == 140737488355328.0

  test "Low":
    check low(FPInt32[4]) is FPInt32[4]
    check low(FPInt32[4]) == -134217728
    check low(FPInt32[8]) == -8388608
    check low(FPInt32[16]) == -32768

    check low(FPInt64[4]) is FPInt64[4]
    check low(FPInt64[4]) == -5.764607523034235e+17
    check low(FPInt64[8]) == -36028797018963970.0
    check low(FPInt64[16]) == -140737488355328.0

  test "as":
    check (10 as 4.fp32(8)) == 10.fp32(8)
    check (10 as 4.fp64(8)) == 10.fp64(8)

  test "underlying":
    check underlying(fp32(4, 8)) is int32
    check underlying(fp64(4, 8)) is int64

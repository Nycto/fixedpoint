import std/[unittest, math], fixedpoint, util

template defineTests(name: string, build: untyped, p: static Natural) =
  suite "Fixed point math at precision " & $p & " for " & name:
    test "toInt":
      check build(1, p).toInt == 1
      check build(1.5, p).toInt == 1
      check build(2, p).toInt == 2

    test "toFloat":
      check build(1, p) == 1.0
      check build(1.7, p) == 1.7

defineTests("FPInt32", fp32, 4)
defineTests("FPInt32", fp32, 8)
defineTests("FPInt32", fp32, 16)

defineTests("FPInt64", fp64, 4)
defineTests("FPInt64", fp64, 8)
defineTests("FPInt64", fp64, 16)

suite "Variable fixed point precision":
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

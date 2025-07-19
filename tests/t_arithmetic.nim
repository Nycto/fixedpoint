import std/[unittest, math], fixedpoint, util

template defineTests(fp: untyped, p: static Natural) =
  suite "Fixed point math at precision for " & $typeof(fp(5, p)):
    test "Addition":
      check 1.fp(p) + 1.fp(p) == 2.fp(p)
      check 1.5.fp(p) + 1.2.fp(p) == 2.7.fp(p)

    test "Subtraction":
      check 1.fp(p) - 1.fp(p) == 0.0
      check 1.5.fp(p) - 1.2.fp(p) == 0.3

defineTests(fp32, 4)
defineTests(fp32, 8)
defineTests(fp32, 16)

defineTests(fp64, 4)
defineTests(fp64, 8)
defineTests(fp64, 16)

import std/[unittest, math], fixedpoint

template defineTests(fp: untyped, p: static Natural) =
  suite "Fixed point comparison at precision for " & $typeof(fp(5, p)):
    test "Less than":
      check 1.fp(p) < 2.fp(p)
      check 1.fp(p) < 8.fp(p)
      check 1.5.fp(p) < 2.5.fp(p)
      check 1.5.fp(p) < 8.5.fp(p)

      check 1 < 2.fp(p)
      check 1.fp(p) < 2

    test "Greater than":
      check 2.fp(p) > 1.fp(p)
      check 8.fp(p) > 1.fp(p)
      check 2.5.fp(p) > 1.5.fp(p)
      check 8.5.fp(p) > 1.5.fp(p)
      check 2 > 1.fp(p)
      check 2.fp(p) > 1

    test "Less than equal to":
      check 1.fp(p) <= 2.fp(p)
      check 1.fp(p) <= 8.fp(p)
      check 1.5.fp(p) <= 2.5.fp(p)
      check 1.5.fp(p) <= 8.5.fp(p)
      check 1.fp(p) <= 1.fp(p)
      check 1 <= 2.fp(p)
      check 1.fp(p) <= 8

defineTests(fp32, 4)
defineTests(fp32, 8)
defineTests(fp32, 16)

defineTests(fp64, 4)
defineTests(fp64, 8)
defineTests(fp64, 16)

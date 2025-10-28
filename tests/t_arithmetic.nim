import std/[unittest, math], fixedpoint

include util

template defineTests(fp: untyped, p: static Natural) =
  suite "Fixed point math at precision for " & $typeof(fp(5, p)):
    test "Addition":
      check 1.fp(p) + 1.fp(p) == 2.fp(p)
      check 1.5.fp(p) + 1.2.fp(p) == 2.7.fp(p)

    test "Subtraction":
      check 1.fp(p) - 1.fp(p) == 0.0
      check 1.5.fp(p) - 1.2.fp(p) == 0.3

    test "Multiply":
      check 2.fp(p) * 4.fp(p) == 8.fp(p)
      check 2.5.fp(p) * 4.5.fp(p) == 11.25.fp(p)

    test "Negative number multiplication":
      check 2.fp(p) * -4.fp(p) == -8.fp(p)
      check -2.fp(p) * 4.fp(p) == -8.fp(p)
      check -2.5.fp(p) * -4.5.fp(p) == 11.25.fp(p)
      check 0.fp(p) * -4.fp(p) == 0.fp(p)
      check -2.fp(p) * 0.fp(p) == 0.fp(p)

    test "Divide":
      check 8.fp(p) / 4.fp(p) == 2.fp(p)
      check 11.25.fp(p) / 4.5.fp(p) == 2.5.fp(p)

    test "Divide":
      check 8.fp(p) div 4.fp(p) == 2.fp(p)
      check 11.25.fp(p) div 4.5.fp(p) == 2.5.fp(p)

    test "In place operators":
      var a = 2.fp(p)

      a += 3.fp(p)
      check a == 5.fp(p)

      a -= 1.fp(p)
      check a == 4.fp(p)

      a *= 2.fp(p)
      check a == 8.fp(p)

      a /= 4.fp(p)
      check a == 2.fp(p)

    test "Absolute value":
      check abs(-1.5.fp(p)) == 1.5.fp(p)
      check abs(1.5.fp(p)) == 1.5.fp(p)

    test "Unary negation":
      check -fp(-1.5, p) == fp(1.5, p)
      check -(fp(1.5, p)) == fp(-1.5, p)

    for i in [0, 4, 9, 17, 23, 90, 100]:
      test "Square root of " & $i:
        check sqrt(i.fp(p)) == sqrt(i.float32)

    for i in [0.96875, 0.5, 0.25, 0.1]:
      test "Square root of " & $i:
        check sqrt(i.fp(p)) == sqrt(i.float32)

    let highValue = high(typeof(0.fp(p)))
    let lowValue = low(typeof(0.fp(p)))

    test "Multiplication overflow saturation":
      check highValue * 2.fp(p) == highValue
      check highValue * -2.fp(p) == lowValue
      check 2.fp(p) * highValue == highValue
      check -2.fp(p) * highValue == lowValue

    test "Multiplication underflow triggers assertion":
      check lowValue * 2.fp(p) == lowValue
      check lowValue * -2.fp(p) == highValue
      check 2.fp(p) * lowValue == lowValue
      check -2.fp(p) * lowValue == highValue

    test "Addition overflow saturation":
      check highValue + 2.fp(p) == highValue
      check 2.fp(p) + highValue == highValue

    test "Addition underflow saturation":
      check lowValue + -2.fp(p) == lowValue
      check -2.fp(p) + lowValue == lowValue

    test "Addition symmetry saturation":
      check highValue + -2.fp(p) == highValue - 2.fp(p)
      check lowValue + 2.fp(p) == lowValue + 2.fp(p)

defineTests(fp32, 4)
defineTests(fp32, 8)

defineTests(fp64, 4)
defineTests(fp64, 8)
defineTests(fp64, 16)

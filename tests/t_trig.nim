import std/[unittest, math], fixedpoint, util

template defineTests(fp: untyped, p: static Natural) =
  suite "Fixed point trig at precision for " & $typeof(fp(5, p)):
    test "Radian normalization":
      # Test normalizing angles in the range (-π, π) - should remain unchanged
      check normalizeRads(0.0.fp(p)) == 0.0
      check normalizeRads((PI / 2).fp(p)) == PI / 2
      check normalizeRads(PI.fp(p) * 0.99) == PI * 0.99
      check normalizeRads((-PI / 2).fp(p)) == -PI / 2
      check normalizeRads(-PI.fp(p) * 0.99) == -PI * 0.99

      # Test normalizing angles > π
      check normalizeRads((PI + 0.1).fp(p)) == -PI + 0.1
      check normalizeRads((3 * PI / 2).fp(p)) == -PI / 2
      check normalizeRads((2 * PI).fp(p)) == 0.0
      check normalizeRads((2 * PI + PI / 4).fp(p)) == PI / 4

      # Test normalizing angles < -π
      check normalizeRads((-PI - 0.1).fp(p)) == PI - 0.1
      check normalizeRads((-3 * PI / 2).fp(p)) == PI / 2
      check normalizeRads((-2 * PI).fp(p)) == 0.0
      check normalizeRads((-2 * PI - PI / 4).fp(p)) == -PI / 4

      # Test with large angles (multiple rotations)
      check normalizeRads((10 * PI).fp(p)) == 0.0
      check normalizeRads((-10 * PI).fp(p)) == 0.0
      # For 9π, the result should be approximately -π due to how the algorithm normalizes
      check normalizeRads((9 * PI).fp(p)) == -PI

    for angle in [0.0, PI / 6, PI / 4, PI / 3, PI / 2, PI, 3 * PI / 2, 2 * PI]:
      test "Cosine of " & $angle & " radians":
        check cos(angle.fp(p)) == cos(angle)

      test "Sine of " & $angle & " radians":
        check sin(angle.fp(p)) == sin(angle)

defineTests(fp32, 8)
defineTests(fp32, 16)

defineTests(fp64, 8)
defineTests(fp64, 16)

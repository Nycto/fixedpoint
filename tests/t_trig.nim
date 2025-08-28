import std/[unittest, math], fixedpoint
include util

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

    test "Radians to degrees conversion":
      check radToDeg(0.0.fp(p)) == 0.0
      check radToDeg((PI / 2).fp(p)) == 90.0
      check radToDeg(PI.fp(p)) == 180.0
      check radToDeg((3 * PI / 2).fp(p)) == 270.0
      check radToDeg((2 * PI).fp(p)) == 360.0
      check radToDeg((-PI / 2).fp(p)) == -90.0

    test "Degrees to radians conversion":
      check degToRad(0.0.fp(p)) == 0.0
      check degToRad(90.0.fp(p)) == PI / 2
      check degToRad(180.0.fp(p)) == PI
      check degToRad(270.0.fp(p)) == 3 * PI / 2
      check degToRad(360.0.fp(p)) == 2 * PI
      check degToRad(-90.0.fp(p)) == -PI / 2

    for angle in [0.0, PI / 6, PI / 4, PI / 3, PI / 2, PI, 3 * PI / 2, 2 * PI]:
      test "Cosine of " & $angle & " radians":
        check cos(angle.fp(p)) == cos(angle)

      test "Sine of " & $angle & " radians":
        check sin(angle.fp(p)) == sin(angle)

    # For arctan2 testing, we need to allow for larger epsilon values
    # due to the approximation used in the implementation
    let tolerance = 0.06.fp(p)

    # Test arctan2 for different input values across all quadrants
    for (a, b) in [
      # First quadrant (x > 0, y > 0)
      (1.0, 1.0),
      (1.0, 2.0),
      # Second quadrant (x < 0, y > 0)
      (1.0, -1.0),
      (2.0, -1.0),
      # Third quadrant (x < 0, y < 0)
      (-1.0, -1.0),
      (-1.0, -2.0),
      # Fourth quadrant (x > 0, y < 0)
      (-1.0, 1.0),
      (-2.0, 1.0),
    ]:
      test "Arctan2 of " & $a & " and " & $b:
        check abs(arctan2(a.fp(p), b.fp(p)) - math.arctan2(a, b).fp(p)) <= tolerance

    test "arctan2 special cases":
      # Special cases should be exact since they use direct constant assignments

      # x = 0
      check arctan2(1.0.fp(p), 0.0.fp(p)) == (PI / 2) # PI/2
      check arctan2(-1.0.fp(p), 0.0.fp(p)) == (-PI / 2) # -PI/2

      # y = 0
      check arctan2(0.0.fp(p), 1.0.fp(p)) == 0.0 # 0
      check arctan2(0.0.fp(p), -1.0.fp(p)) == PI # PI

      # Both x and y are 0 (special case)
      check arctan2(0.0.fp(p), 0.0.fp(p)) == 0.0 # Convention: defined as 0

defineTests(fp32, 8)
defineTests(fp32, 16)

defineTests(fp64, 8)
defineTests(fp64, 16)

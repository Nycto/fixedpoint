import std/[unittest, math], fixedpoint

proc `==`*(found: FixedPoint, expect: SomeNumber): bool =
  let delta = abs(found.toFloat.float64 - expect.float64)
  let epsilon = 1.0 / (5.0 * found.precision.float64)
  checkpoint "Expected: " & $expect & ", Found: " & $found
  checkpoint "Delta: " & $delta & ", Epsilon: " & $epsilon
  return delta <= epsilon

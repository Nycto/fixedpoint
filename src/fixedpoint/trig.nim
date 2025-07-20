import base, arithmetic
import std/math

proc normalizeRads*(value: FixedPoint): typeof(value) =
  ## Normalizes the angle (in radians) to be in the range of -π to π
  const pi2 = (2.0 * PI) as value
  result = value
  while result >= (PI as value):
    result = result - pi2
  while result < -(PI as value):
    result = result + pi2

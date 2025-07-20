import base, arithmetic
import std/math

proc radToDeg*(value: FixedPoint): typeof(value) =
  ## Converts an angle from radians to degrees
  const oneEighty = 180.0 as value
  const pi = PI as value
  return value * oneEighty / pi

proc degToRad*(value: FixedPoint): typeof(value) =
  ## Converts an angle from degrees to radians
  const oneEighty = 180.0 as value
  const pi = PI as value
  return value * pi / oneEighty

proc normalizeRads*(value: FixedPoint): typeof(value) =
  ## Normalizes the angle (in radians) to be in the range of -π to π
  const pi2 = (2.0 * PI) as value
  result = value
  while result >= (PI as value):
    result = result - pi2
  while result < -(PI as value):
    result = result + pi2

proc cos*(value: FixedPoint): typeof(value) =
  ## Calculates the cosine of a fixed-point number (in radians)
  ## Uses a Taylor series approximation for accuracy

  # Normalize to -π to π range
  let normalized = normalizeRads(value)

  # Use a 6-term Taylor series approximation for cos(x)
  # cos(x) = 1 - x²/2! + x⁴/4! - x⁶/6! + x⁸/8! - x¹⁰/10!

  const one = 1.0 as value

  # For better accuracy in fixed-point math, we'll use a reduced
  # Taylor series and special-case the common angles

  # Special cases for common angles for better accuracy
  if normalized == (0.0 as value):
    return one
  elif normalized == (PI as value) or normalized == -(PI as value):
    return -one
  elif normalized == (PI / 2 as value) or normalized == -(PI / 2 as value):
    return 0.0 as value

  # Use a 6-term Taylor series approximation for cos(x)
  # cos(x) = 1 - x²/2! + x⁴/4! - x⁶/6! + x⁸/8! - x¹⁰/10!
  let x2 = normalized * normalized # x²

  # Calculate factorial terms as reciprocals for better fixed-point performance
  const fact2Inv = (1.0 / 2.0) as value
  const fact4Inv = (1.0 / 24.0) as value
  const fact6Inv = (1.0 / 720.0) as value
  const fact8Inv = (1.0 / 40320.0) as value
  const fact10Inv = (1.0 / 3628800.0) as value

  # Calculate the terms with multiplication instead of division
  let term1 = one
  let term2 = x2 * fact2Inv

  let x4 = x2 * x2
  let term3 = x4 * fact4Inv

  let x6 = x4 * x2
  let term4 = x6 * fact6Inv

  let x8 = x6 * x2
  let term5 = x8 * fact8Inv

  let x10 = x8 * x2
  let term6 = x10 * fact10Inv

  # Return the final result
  return term1 - term2 + term3 - term4 + term5 - term6

proc sin*(value: FixedPoint): typeof(value) =
  ## Calculates the sine of a fixed-point number (in radians)

  # Normalize to -π to π range
  let normalized = normalizeRads(value)

  # Special cases for common angles for better accuracy
  const one = 1.0 as value
  const zero = 0.0 as value

  if normalized == zero:
    return zero
  elif normalized == (PI as value) or normalized == -(PI as value):
    return zero
  elif normalized == (PI / 2 as value):
    return one
  elif normalized == -(PI / 2 as value):
    return -one

  # Using sin(x) = cos(PI/2 - x) which is mathematically equivalent to cos(x - PI/2)
  # but less prone to overflow for values near 3π/2
  const halfPi = (PI / 2) as value
  return cos(halfPi - normalized)

proc arctan2*(y, x: FixedPoint): typeof(y) =
  ## Calculates the arctangent of y/x, taking into account the signs of both arguments
  ## to determine the quadrant of the result. Returns the angle in radians.
  ## The result is in the range [-π, π].

  const zero = 0.0 as y
  const one = 1.0 as y
  const pi = PI as y
  const halfPi = (PI / 2) as y

  # Coefficients calibrated for better accuracy with fixed-point
  const a = (1.0 / 3.0) as y
  const b = (1.0 / 5.0) as y
  const c = (1.0 / 7.0) as y
  const d = (1.0 / 9.0) as y

  # Handle special cases
  if x == zero:
    return
      if y > zero:
        halfPi
      elif y < zero:
        -halfPi
      else:
        zero
  elif y == zero:
    return if x > zero: zero else: pi

  # First, work with absolute values and adjust the result based on quadrant later
  let absY = abs(y)
  let absX = abs(x)

  proc polynomialApprox(z: FixedPoint): FixedPoint {.inline.} =
    # More accurate polynomial approximation for atan(z) where z is in [0, 1]
    # atan(z) ≈ z * (1 - a*z² + b*z⁴ - c*z⁶ + d*z⁸)
    let z2 = z * z
    let z4 = z2 * z2
    let z6 = z4 * z2
    let z8 = z6 * z2
    return z * (one - a * z2 + b * z4 - c * z6 + d * z8)

  # Determine which ratio to use to keep z in a range where our approximation works well
  let resultAngle =
    if absY <= absX:
      polynomialApprox(absY / absX)
    else:
      # If y > x, use atan(x/y) = π/2 - atan(y/x)
      halfPi - polynomialApprox(absX / absY)

  # Adjust angle based on the quadrant
  if x > zero:
    if y < zero: # 4th quadrant
      return -resultAngle
    else: # 1st quadrant
      return resultAngle
  else: # x < 0
    if y < zero: # 3rd quadrant
      return -pi + resultAngle
    else: # 2nd quadrant
      return pi - resultAngle

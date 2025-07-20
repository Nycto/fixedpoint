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

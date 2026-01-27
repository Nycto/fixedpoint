import base, util

proc builtinMulOverflow[T: int32 | int64](
  a, b: T, result: var T
): bool {.importc: "__builtin_mul_overflow", nodecl.}

proc builtinSubOverflow[T: int32 | int64](
  a, b: T, result: var T
): bool {.importc: "__builtin_sub_overflow", nodecl.}

proc builtinAddOverflow[T: int32 | int64](
  a, b: T, result: var T
): bool {.importc: "__builtin_add_overflow", nodecl.}

template calculate(a, b, callback, checkSaturation, body, postProcess: untyped) =
  ## Executes a standard operation on two fixed-point numbers
  assert(a.precision == b.precision)

  when nimvm:
    block:
      let it {.inject.} = body
      return typeof(a)(postProcess)
  else:
    block:
      {.push overflowChecks: off.}
      const highValue = typeof(a).high
      const lowValue = typeof(a).low
      var it {.inject.}: underlying(a)
      if callback(underlying(a)(a), underlying(b)(b), it):
        return if checkSaturation: highValue else: lowValue
      return typeof(a)(postProcess)
      {.pop.}

proc `-`*(a, b: FixedPoint): typeof(a) {.raises: [].} =
  ## Subtraction operation
  calculate(
    a,
    b,
    builtinSubOverflow,
    underlying(a)(a) > 0 and underlying(b)(b) < 0,
    underlying(a)(a) - underlying(b)(b),
    it
  )

proc `+`*(a, b: FixedPoint): typeof(a) {.raises: [].} =
  ## Addition operation with saturating arithmetic
  calculate(
    a,
    b,
    builtinAddOverflow,
    underlying(a)(a) > 0 and underlying(b)(b) > 0,
    underlying(a)(a) + underlying(b)(b),
    it,
  )

proc `*`*(a, b: FixedPoint): typeof(a) {.raises: [].} =
  # Fixed point multiplication with saturating arithmetic
  calculate(
    a,
    b,
    builtinMulOverflow,
    (underlying(a)(a) > 0 and underlying(b)(b) > 0) or
      (underlying(a)(a) < 0 and underlying(b)(b) < 0),
    int64(a) * int64(b),
    it shr a.precision,
  )

proc `/`*(a, b: FixedPoint): typeof(a) {.inline.} =
  # Fixed point division
  assert(a.precision == b.precision)
  return typeof(a)(int64(a) shl a.precision div int64(b))

template `div`*(a, b: FixedPoint): auto =
  # Fixed point division
  a / b

template defineMathInterop(op: untyped) =
  ## Creates interop functions for fixed-point numbers with standard numbers
  proc `op`*(a: SomeNumber, b: FixedPoint): typeof(b) =
    `op`(`as`(a, b)) `op` b

  proc `op`*(a: FixedPoint, b: SomeNumber): typeof(a) =
    `op`(a, `as`(b, a))

defineMathInterop(`+`)
defineMathInterop(`-`)
defineMathInterop(`*`)
defineMathInterop(`/`)
defineMathInterop(`div`)

template defineInplace(op, baseOp: untyped) =
  proc `op`*(a: var FixedPoint, b: typeof(a)) =
    a = `baseOp`(a, b)

defineInplace(`+=`, `+`)
defineInplace(`-=`, `-`)
defineInplace(`*=`, `*`)
defineInplace(`/=`, `/`)

template defineUnary(op: untyped) =
  proc `op`*(value: FixedPoint): typeof(value) {.inline.} =
    return typeof(value)(`op`(underlying(value)(value)))

defineUnary(`-`)
defineUnary(`abs`)

proc sqrt*(value: FixedPoint): typeof(value) =
  ## Calculates the square root of a fixed point number without converting to a floating point
  assert(underlying(value)(value) >= 0, "Cannot take square root of negative number")

  const one = underlying(value)(1 as value)
  if underlying(value)(value) == one or underlying(value)(value) == 0:
    return value

  const half = 0.5 as value
  const epsilon = typeof(value)(4)

  # Use Newton's method

  result =
    if underlying(value)(value) > one:
      value.toInt.isqrt as value
    else:
      typeof(value)(one)

  for i in 0 .. 10:
    let previous = result
    let next = half * (result + value / result)
    if next.int32 == 0:
      break
    result = next
    if abs(result - previous) <= epsilon:
      break

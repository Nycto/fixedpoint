import base, util

template defineMathInterop(op: untyped) =
  proc `op`*(a: SomeNumber, b: FixedPoint): typeof(b) =
    `op`(`as`(a, b)) `op` b

  proc `op`*(a: FixedPoint, b: SomeNumber): typeof(a) =
    `op`(a, `as`(b, a))

template defineMathOp(op: untyped) =
  proc `op`*(a, b: FixedPoint): typeof(a) =
    assert(a.precision == b.precision)
    typeof(a)(`op`(underlying(a)(a), underlying(b)(b)))

  defineMathInterop(op)

defineMathOp(`+`)
defineMathOp(`-`)

proc `*`*(a, b: FixedPoint): typeof(a) {.inline.} =
  # Fixed point multipliation
  assert(a.precision == b.precision)
  return typeof(a)(int64(a) * int64(b) shr a.precision)

proc `/`*(a, b: FixedPoint): typeof(a) {.inline.} =
  # Fixed point division
  assert(a.precision == b.precision)
  return typeof(a)(int64(a) shl a.precision / int64(b))

template `div`*(a, b: FixedPoint): auto =
  # Fixed point division
  a / b

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

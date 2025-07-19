import base

template defineMathInterop(op: untyped) =
  proc `op`*(a: SomeInteger, b: FixedPoint): typeof(b) =
    (a as b) `op` b

  proc `op`*(a: FixedPoint, b: SomeInteger): typeof(a) =
    a `op` (b as a)

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

defineMathInterop(`*`)
defineMathInterop(`/`)

import base

template defineCompareOp(op: untyped) =
  proc `op`*(a, b: FixedPoint): bool {.inline.} =
    assert(a.precision == b.precision)
    return `op`(underlying(a)(a), underlying(b)(b))

  proc `op`*(a: FixedPoint, b: SomeNumber): bool {.inline.} =
    op(a, b as a)

  proc `op`*(a: SomeNumber, b: FixedPoint): bool {.inline.} =
    op(a as b, b)

defineCompareOp(`==`)
defineCompareOp(`<`)
defineCompareOp(`<=`)

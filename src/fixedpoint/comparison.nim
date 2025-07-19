import base

template defineCompareOp(op: untyped) =
  proc `op`*(a, b: FixedPoint): bool {.inline.} =
    assert(a.precision == b.precision)
    return `op`(underlying(a)(a), underlying(b)(b))

defineCompareOp(`==`)
defineCompareOp(`<`)
defineCompareOp(`<=`)

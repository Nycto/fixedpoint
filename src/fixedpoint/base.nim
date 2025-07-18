##
## Decimal values using an integer and a precision
##
import macros

type
  FPInt32*[P: static Natural] = distinct int32
    ## 32-bit fixed point decimal with P bits of precision

  FPInt64*[P: static Natural] = distinct int64
    ## 64-bit fixed point decimal with P bits of precision

  FixedPoint* = FPInt32 | FPInt64 ## Any type of fixed point number

proc fp*(value: SomeInteger, precision: static Natural): FPInt32[precision] =
  ## Creates a fixed point number
  FPInt32[precision](value shl precision)

proc fp*(value: SomeFloat, precision: static Natural): FPInt32[precision] =
  ## Creates a fixed point number
  FPInt32[precision](int32(value * (1 shl precision)))

proc fp64*(value: SomeInteger, precision: static Natural): FPInt64[precision] =
  ## Creates a fixed point number
  FPInt64[precision](value shl precision)

proc fp64*(value: SomeFloat, precision: static Natural): FPInt64[precision] =
  ## Creates a fixed point number
  FPInt64[precision](int64(value * (1 shl precision)))

macro precision*(num: FixedPoint): Natural =
  ## Returns the precision of a fixed point number
  let typ = num.getTypeInst
  typ.expectKind(nnkBracketExpr)
  typ[0].expectKind(nnkSym)
  typ[1].expectKind(nnkIntLit)
  return typ[1]

template underlying*(value: FixedPoint): typedesc =
  ## Returns the underlying type of a fixed point number
  when value is FPInt32: int32 else: int64

proc toInt*(d: FixedPoint): auto =
  cast[underlying(d)](d) shr d.precision

proc toFloat*(d: FixedPoint): auto =
  cast[underlying(d)](d) / (1 shl d.precision)

template `as`*(value: typed, prototype: FixedPoint): typeof(prototype) =
  ## Ensures the given value is the same type as the prototype
  typeof(prototype)(fp(value, prototype.precision))

proc `$`*(d: FixedPoint): string =
  $d.toFloat

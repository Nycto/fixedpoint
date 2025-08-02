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

proc fp32*(value: SomeInteger, precision: static Natural): FPInt32[precision] =
  ## Creates a fixed point number
  FPInt32[precision](value shl precision)

proc fp32*(value: SomeFloat, precision: static Natural): FPInt32[precision] =
  ## Creates a fixed point number
  FPInt32[precision](int32(value * (1 shl precision)))

proc fp64*(value: SomeInteger, precision: static Natural): FPInt64[precision] =
  ## Creates a fixed point number
  FPInt64[precision](value shl precision)

proc fp64*(value: SomeFloat, precision: static Natural): FPInt64[precision] =
  ## Creates a fixed point number
  FPInt64[precision](int64(value * (1 shl precision)))

proc findPrecision(typ: NimNode, original: NimNode = typ): NimNode =
  case typ.kind
  of nnkConstDef:
    return typ[2].findPrecision(original)
  of nnkIntLit:
    return typ
  of nnkBracketExpr:
    typ.expectKind(nnkBracketExpr)
    typ[0].expectKind(nnkSym)
    return typ[1].findPrecision(original)
  of nnkSym:
    return typ.getImpl().findPrecision(original)
  of nnkTypeDef:
    return typ[2].findPrecision(original)
  else:
    error("Invalid type for precision: " & lispRepr(typ), original)

macro precision*(num: FixedPoint): Natural =
  ## Returns the precision of a fixed point number
  return num.getTypeInst.findPrecision

template underlying*(value: FixedPoint | typedesc[FixedPoint]): typedesc =
  ## Returns the underlying type of a fixed point number
  when value is FPInt32: int32 else: int64

proc toInt*(d: FixedPoint): auto =
  cast[underlying(d)](d) shr d.precision

proc toFloat*(d: FixedPoint): auto =
  cast[underlying(d)](d) / (1 shl d.precision)

template `as`*(value: typed, prototype: FixedPoint): typeof(prototype) =
  ## Ensures the given value is the same type as the prototype
  when prototype is FPInt32:
    typeof(prototype)(fp32(value, prototype.precision))
  else:
    typeof(prototype)(fp64(value, prototype.precision))

proc `$`*(d: FixedPoint): string =
  $d.toFloat

proc high*(typ: typedesc[FixedPoint]): typ =
  return typeof(result)(high(typ.underlying))

proc low*(typ: typedesc[FixedPoint]): typ =
  return typeof(result)(low(typ.underlying))

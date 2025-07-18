
proc isqrt*(n: SomeInteger): SomeInteger =
  ## See https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_(base_2)
  assert(n >= 0, "sqrt input should be non-negative")

  var x = n
  result = 0

  var d: int32 = 1 shl 30
  while d > n:
    d = d shr 2

  while d != 0:
    if x >= result + d:
      x -= result + d
      result = (result shr 1) + d
    else:
      result = result shr 1
    d = d shr 2

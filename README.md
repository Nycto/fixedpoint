# FixedPoint

[![Build](https://github.com/Nycto/fixedpoint/actions/workflows/build.yml/badge.svg)](https://github.com/Nycto/fixedpoint/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](https://github.com/Nycto/fixedpoint/blob/main/LICENSE)
[![API Documentation](https://img.shields.io/badge/nim-documentation-blue)](https://nycto.github.io/fixedpoint/)

A native Nim fixed-point math library

## Features

- **Integer-based implementation**: Uses integers internally for calculations, avoiding floating-point rounding errors
- **Configurable precision**: Choose the number of fractional bits that suits your needs
- **32-bit and 64-bit variants**: `FPInt32` and `FPInt64` types to balance between range and memory usage
- **Comprehensive math operations**:
  - Basic arithmetic (`+`, `-`, `*`, `/`)
  - Comparison operators (`==`, `<`, `<=`)
  - Absolute value and negation
  - Square root calculation
  - Trigonometric functions (sin, cos, arctan2)
  - Angle conversions (radians/degrees)
- **No external dependencies**: Pure Nim implementation

## Usage

### Basic Operations

```nim
import fixedpoint

# Create fixed-point numbers with 8 bits of precision
let a = fp32(10.5, 8)  # 32-bit fixed-point
let b = fp64(3.25, 8)  # 64-bit fixed-point

# Basic arithmetic
let sum = a + a         # 21.0
let difference = a - b  # 7.25
let product = a * b     # 34.125
let quotient = a / b    # 3.23077

# Convert back to integers or floats
echo a.toInt()   # 10
echo a.toFloat() # 10.5

# In-place operations
var c = fp32(5.0, 8)
c += a  # c = 15.5
c -= b  # c = 12.25
c *= b  # c = 39.8125
c /= a  # c = 3.7917

# Type conversion
let d = 42 as a  # Convert integer to same type as 'a'
```

### Comparisons

```nim
import fixedpoint

let a = fp32(10.5, 8)
let b = fp32(3.25, 8)

echo a == b  # false
echo a < b   # false
echo a <= b  # false
echo a > b   # true - derived from < operator
echo a >= b  # true - derived from <= operator
echo a != b  # true - derived from == operator
```

### Mathematical Functions

```nim
import fixedpoint

let a = fp32(9.0, 16)
echo sqrt(a)  # 3.0

# Trigonometric functions (in radians)
let angle = fp32(PI/4, 16)  # 45 degrees in radians
echo cos(angle)  # ~0.7071
echo sin(angle)  # ~0.7071

# Convert between radians and degrees
let degrees = fp32(90.0, 16)
let radians = degToRad(degrees)  # ~1.5708
echo radToDeg(radians)  # 90.0

# Two-argument arctangent
let y = fp32(1.0, 16)
let x = fp32(1.0, 16)
echo arctan2(y, x)  # ~0.7854 (45 degrees in radians)
```

## Precision and Range

The precision parameter `P` determines how many bits are used for the fractional part. Higher precision gives more accurate decimal representations but reduces the available range.

| Type       | Precision | Range                             | Smallest Value         |
|------------|-----------|-----------------------------------|------------------------|
| FPInt32[4] | 4 bits    | ±134,217,728 (approx. ±2^27)      | 0.0625 (1/16)          |
| FPInt32[8] | 8 bits    | ±8,388,608 (approx. ±2^23)        | 0.00390625 (1/256)     |
| FPInt32[16]| 16 bits   | ±32,768 (approx. ±2^15)           | 0.0000152587 (1/65536) |
| FPInt64[4] | 4 bits    | ±5.76×10^17 (approx. ±2^59)       | 0.0625 (1/16)          |
| FPInt64[8] | 8 bits    | ±3.6×10^16 (approx. ±2^55)        | 0.00390625 (1/256)     |
| FPInt64[16]| 16 bits   | ±1.4×10^14 (approx. ±2^47)        | 0.0000152587 (1/65536) |

Choose the appropriate type and precision based on your application's needs:
- Use higher precision for more accurate calculations
- Use lower precision for greater range
- Use 64-bit variants for applications requiring both high precision and large range

## Performance Considerations

- Fixed-point arithmetic is generally faster than floating-point for many operations, especially on hardware without an FPU
- Multiplication and division are implemented with care to maintain precision
- Square root and trigonometric functions use optimized algorithms for fixed-point calculations

## Limitations

- Range is inversely proportional to precision
- The library doesn't handle division by zero
- Trigonometric functions use approximations and may have small errors

## License

This library is available under the MIT License.

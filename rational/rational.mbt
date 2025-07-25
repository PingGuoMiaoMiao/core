// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// TODO:
// - Add a trait for `Integer` and make `Rational` generic as `Rational[T: Integer]`. Currently, the numerator and denominator are specific to `Int64` types.
// - `to_double` method needs fix. See its comment.

///|
/// Rational number type.
///
/// Invariants:
/// - The denominator is always positive.
/// - The numerator and denominator are always coprime.
struct T {
  numerator : Int64
  denominator : Int64
}

///|
fn gcd(a : Int64, b : Int64) -> Int64 {
  for a = a, b = b {
    if b == 0L {
      break a
    }
    continue b, a % b
  }
}

///|
/// Creates a rational number from the given numerator and denominator.
///
/// Parameters:
///
/// * `numerator` : The numerator of the rational number.
/// * `denominator` : The denominator of the rational number.
///
/// Returns `Some(rational)` if the denominator is non-zero, where the rational
/// number is automatically reduced to its simplest form with a positive
/// denominator. Returns `None` if the denominator is zero.
///
/// Example:
///
/// ```moonbit
/// // Create 3/4
/// let r1 = @rational.new(3L, 4L)
/// inspect(r1, content="Some(3/4)")
///
/// // Create -1/2 (negative numerator)
/// let r2 = @rational.new(-1L, 2L)
/// inspect(r2, content="Some(-1/2)")
///
/// // Create -1/2 (negative denominator gets normalized)
/// let r3 = @rational.new(1L, -2L)
/// inspect(r3, content="Some(-1/2)")
///
/// // Create 1/2 (double negatives cancel out)
/// let r4 = @rational.new(-1L, -2L)
/// inspect(r4, content="Some(1/2)")
///
/// // Automatic reduction to simplest form
/// let r5 = @rational.new(6L, 9L)
/// inspect(r5, content="Some(2/3)")
///
/// // Division by zero returns None
/// let r6 = @rational.new(1L, 0L)
/// inspect(r6, content="None")
/// ```
///
pub fn new(numerator : Int64, denominator : Int64) -> T? {
  if denominator == 0L {
    None
  } else {
    let sign = if (numerator < 0L && denominator < 0L) ||
      (numerator > 0L && denominator > 0L) {
      1L
    } else {
      -1L
    }
    let numerator = numerator.abs()
    let denominator = denominator.abs()
    let gcd = gcd(numerator, denominator)
    Some({ numerator: sign * numerator / gcd, denominator: denominator / gcd })
  }
}

///|
/// Creates a rational number without enforcing invariants.
fn new_unchecked(numerator : Int64, denominator : Int64) -> T {
  let gcd = gcd(numerator.abs(), denominator)
  { numerator: numerator / gcd, denominator: denominator / gcd }
}

///|
/// NOTE: we don't check overflow here, to align with the `op_add` of `Int64`.
/// TODO: add a `checked_add` method.
pub impl Add for T with op_add(self : T, other : T) -> T {
  new_unchecked(
    self.numerator * other.denominator + other.numerator * self.denominator,
    self.denominator * other.denominator,
  )
}

///|
/// Subtracts one rational number from another.
///
/// Parameters:
///
/// * `self` : The minuend (rational number to subtract from).
/// * `other` : The subtrahend (rational number to subtract).
///
/// Returns the difference of the two rational numbers.
///
/// Example:
///
/// ```moonbit
/// let a = @rational.new(1L, 2L).unwrap() // 1/2
/// let b = @rational.new(1L, 3L).unwrap() // 1/3
/// inspect(a - b, content="1/6") // 1/2 - 1/3 = 1/6
/// ```
///
pub impl Sub for T with op_sub(self : T, other : T) -> T {
  new_unchecked(
    self.numerator * other.denominator - other.numerator * self.denominator,
    self.denominator * other.denominator,
  )
}

///|
/// Multiplies two rational numbers.
///
/// Parameters:
///
/// * `self` : The first rational number.
/// * `other` : The second rational number to multiply with.
///
/// Returns the product of the two rational numbers.
///
/// Example:
///
/// ```moonbit
/// let a = @rational.new(1L, 2L).unwrap() // 1/2
/// let b = @rational.new(2L, 3L).unwrap() // 2/3
/// let c = a * b // 1/3
/// inspect(c, content="1/3")
/// ```
///
pub impl Mul for T with op_mul(self : T, other : T) -> T {
  new_unchecked(
    self.numerator * other.numerator,
    self.denominator * other.denominator,
  )
}

///|
/// Divides one rational number by another.
///
/// Parameters:
///
/// * `self` : The dividend rational number.
/// * `other` : The divisor rational number.
///
/// Returns the quotient of the division as a rational number.
///
/// Example:
///
/// ```moonbit
/// let a = @rational.new(1L, 2L) // 1/2
/// let b = @rational.new(2L, 3L) // 2/3
/// match (a, b) {
///   (Some(x), Some(y)) => {
///     let result = x / y // 3/4
///     inspect(result, content="3/4")
///   }
///   _ => ()
/// }
/// ```
///
pub impl Div for T with op_div(self : T, other : T) -> T {
  if other.numerator < 0L {
    new_unchecked(
      self.numerator * -other.denominator,
      self.denominator * -other.numerator,
    )
  } else {
    new_unchecked(
      self.numerator * other.denominator,
      self.denominator * other.numerator,
    )
  }
}

///|
/// Returns the multiplicative inverse of a rational number.
///
/// Parameters:
///
/// * `self` : The rational number to find the reciprocal of.
///
/// Returns a new rational number that is the reciprocal of the input.
///
/// Example:
///
/// ```moonbit
/// let half = @rational.new(1L, 2L).unwrap()
/// let two = half.reciprocal()
/// inspect(two, content="2")
///
/// let negative_third = @rational.new(-1L, 3L).unwrap()
/// let negative_three = negative_third.reciprocal()
/// inspect(negative_three, content="-3")
/// ```
///
pub fn reciprocal(self : T) -> T {
  if self.numerator < 0L {
    new_unchecked(-self.denominator, -self.numerator)
  } else {
    new_unchecked(self.denominator, self.numerator)
  }
}

///|
/// Returns the negation of a rational number.
///
/// Parameters:
///
/// * `self` : The rational number to negate.
///
/// Returns a new rational number with the opposite sign.
///
/// Example:
///
/// ```moonbit
/// let positive = @rational.new(3L, 4L).unwrap()
/// let negative = positive.neg()
/// inspect(negative.to_string(), content="-3/4")
///
/// let negative_original = @rational.new(-5L, 2L).unwrap()
/// let positive_result = negative_original.neg()
/// inspect(positive_result.to_string(), content="5/2")
/// ```
///
pub fn T::neg(self : T) -> T {
  new_unchecked(-self.numerator, self.denominator)
}

///|
/// Returns the absolute value of a rational number.
///
/// Parameters:
///
/// * `self` : The rational number to get the absolute value of.
///
/// Returns a new rational number representing the absolute value of the input.
///
/// Example:
///
/// ```moonbit
/// let positive = @rational.new(3L, 4L).unwrap()
/// let negative = @rational.new(-3L, 4L).unwrap()
/// inspect(positive.abs(), content="3/4")
/// inspect(negative.abs(), content="3/4")
/// ```
///
pub fn T::abs(self : T) -> T {
  new_unchecked(self.numerator.abs(), self.denominator)
}

///|
/// Compares two rational numbers for equality.
///
/// Parameters:
///
/// * `self` : The first rational number.
/// * `other` : The second rational number.
///
/// Returns `true` if the two rational numbers are equal, `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// let a = @rational.new(1L, 2L).unwrap()  // 1/2
/// let b = @rational.new(2L, 4L).unwrap()  // 2/4 = 1/2
/// inspect(a == b, content="true")
///
/// let c = @rational.new(1L, 3L).unwrap()  // 1/3
/// inspect(a == c, content="false")
/// ```
///
pub impl Eq for T with op_equal(self : T, other : T) -> Bool {
  self.numerator * other.denominator == other.numerator * self.denominator
}

///|
/// Compares two rational numbers and returns their ordering.
///
/// Parameters:
///
/// * `self` : The first rational number to compare.
/// * `other` : The second rational number to compare.
///
/// Returns an integer indicating the relative order: negative if `self` is less
/// than `other`, zero if they are equal, and positive if `self` is greater than
/// `other`.
///
/// Example:
///
/// ```moonbit
/// let a = @rational.new(1L, 2L).unwrap()  // 1/2
/// let b = @rational.new(2L, 3L).unwrap()  // 2/3
/// inspect(a.compare(b), content="-1")     // 1/2 < 2/3
///
/// let c = @rational.new(3L, 4L).unwrap()  // 3/4
/// let d = @rational.new(3L, 4L).unwrap()  // 3/4
/// inspect(c.compare(d), content="0")      // 3/4 == 3/4
///
/// let e = @rational.new(5L, 6L).unwrap()  // 5/6
/// let f = @rational.new(1L, 2L).unwrap()  // 1/2
/// inspect(e.compare(f), content="1")      // 5/6 > 1/2
/// ```
///
pub impl Compare for T with compare(self : T, other : T) -> Int {
  let left = self.numerator * other.denominator
  let right = other.numerator * self.denominator
  left.compare(right)
}

///|
/// Converts the rational number to its approximate double-precision
/// floating-point representation.
///
/// Parameters:
///
/// * `self` : The rational number to convert.
///
/// Returns the double-precision floating-point approximation of the rational
/// number.
///
/// Example:
///
/// ```moonbit
/// let rational = @rational.new(1L, 2L).unwrap()
/// inspect(rational.to_double(), content="0.5")
///
/// let negative = @rational.new(-3L, 4L).unwrap()
/// inspect(negative.to_double(), content="-0.75")
/// ```
///
pub fn to_double(self : T) -> Double {
  // TODO: complete algorithm
  self.numerator.to_double() / self.denominator.to_double()
}

///|
fn[T] nan_error() -> T raise RationalError {
  raise RationalError("Rational::from_double: cannot convert NaN")
}

///|
fn[T] overflow_error() -> T raise RationalError {
  raise RationalError("Rational::from_double: overflow")
}

///|
/// Error type for rational number operations.
///
/// Constructor:
///
/// * `RationalError(String)` : Error with a descriptive message.
///
/// Example:
///
/// ```moonbit
/// let error = RationalError::RationalError("division by zero")
/// inspect(
///   error,
///   content=(
///     #|RationalError("division by zero")
///   ),
/// )
/// ```
///
pub(all) suberror RationalError String derive(Show, ToJson)

///|
/// Compares two `RationalError` values for equality.
///
/// Parameters:
///
/// * `self` : The first `RationalError` to compare.
/// * `other` : The second `RationalError` to compare.
///
/// Returns `true` if both `RationalError` values contain the same error message,
/// `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// let error1 = @rational.RationalError("division by zero")
/// let error2 = @rational.RationalError("division by zero")
/// let error3 = @rational.RationalError("overflow")
/// inspect(error1 == error2, content="true")
/// inspect(error1 == error3, content="false")
/// ```
///
pub impl Eq for RationalError with op_equal(
  self : RationalError,
  other : RationalError,
) -> Bool {
  match (self, other) {
    (RationalError(e1), RationalError(e2)) => e1 == e2
  }
}

///|
/// Converts a floating-point number to its rational representation using a
/// continued fraction algorithm.
///
/// Parameters:
///
/// * `value` : The double-precision floating-point number to convert to a
/// rational.
///
/// Returns a rational number that approximates the input value.
///
/// Throws an error of type `RationalError` if the input is NaN or if the
/// conversion would result in integer overflow.
///
/// Example:
///
/// ```moonbit
/// // Convert 0.5 to rational 1/2
/// let half = @rational.from_double(0.5)
/// inspect(half, content="1/2")
///
/// // Convert 0.333... to a close rational approximation
/// let third = @rational.from_double(1.0 / 3.0)
/// inspect(third, content="1/3")
/// ```
///
pub fn from_double(value : Double) -> T raise RationalError {
  // continued fraction algorithm
  // Ported from https://github.com/rust-num/num
  if value.is_nan() {
    nan_error()
  }
  let sign = if value < 0.0 { -1L } else { 1L }
  let value = value.abs()
  let mut q = value
  let mut n0 = 0L
  let mut d0 = 1L
  let mut n1 = 1L
  let mut d1 = 0L
  let t_max = @int64.max_value
  let t_max_f = t_max.to_double()
  let epsilon = 1.0 / t_max_f
  let max_iteration = 30
  let max_error = 10.0e-20

  // Overflow
  if q > t_max_f {
    overflow_error()
  }
  for i in 0..<max_iteration {
    if !(q >= -9223372036854775808.0 && q < 9223372036854775808.0) {
      break // overflow
    }
    let a = q.to_int64()
    let a_f = a.to_double()
    let f = q - a_f

    // Prevent overflow
    if !(a == 0L) &&
      (
        n1 > t_max / a ||
        d1 > t_max / a ||
        a * n1 > t_max - n0 ||
        a * d1 > t_max - d0
      ) {
      break
    }
    let n = a * n1 + n0
    let d = a * d1 + d0
    n0 = n1
    d0 = d1
    n1 = n
    d1 = d
    let g = gcd(n1, d1)
    if !(g == 0L) {
      n1 = n1 / g
      d1 = d1 / g
    }

    // Close enough?
    let (n_f, d_f) = (n.to_double(), d.to_double())
    if (n_f / d_f - value).abs() < max_error {
      break
    }

    // Prevent division by ~0
    if f < epsilon {
      break
    }
    q = 1.0 / f
  }
  // Overflow
  if d1 == 0L {
    overflow_error()
  }
  match new(sign * n1, d1) {
    Some(r) => r
    None => abort("Impossible to reach")
  }
}

///|
/// Returns the smallest integer greater than or equal to the rational number.
///
/// Parameters:
///
/// * `self` : The rational number to ceiling.
///
/// Returns the ceiling of the rational number as an `Int64`.
///
/// Example:
///
/// ```moonbit
/// let r1 = @rational.new(3L, 2L).unwrap()  // 3/2 = 1.5
/// inspect(r1.ceil(), content="2")
///
/// let r2 = @rational.new(-3L, 2L).unwrap() // -3/2 = -1.5
/// inspect(r2.ceil(), content="-1")
///
/// let r3 = @rational.new(4L, 2L).unwrap()  // 4/2 = 2.0
/// inspect(r3.ceil(), content="2")
/// ```
///
pub fn T::ceil(self : T) -> Int64 {
  let sign = if self.numerator < 0L { -1L } else { 1L }
  let quotient = self.numerator / self.denominator
  if self.numerator % self.denominator == 0L {
    quotient
  } else {
    quotient + (1L + sign) / 2L
  }
}

///|
/// Computes the largest integer that is less than or equal to the rational
/// number.
///
/// Parameters:
///
/// * `self` : The rational number to floor.
///
/// Returns the largest `Int64` value that is less than or equal to `self`.
///
/// Example:
///
/// ```moonbit
/// let r1 = @rational.new(7L, 3L).unwrap()  // 7/3 ≈ 2.33
/// inspect(r1.floor(), content="2")
///
/// let r2 = @rational.new(-7L, 3L).unwrap()  // -7/3 ≈ -2.33
/// inspect(r2.floor(), content="-3")
///
/// let r3 = @rational.new(6L, 3L).unwrap()  // 6/3 = 2.0
/// inspect(r3.floor(), content="2")
/// ```
///
pub fn T::floor(self : T) -> Int64 {
  let sign = if self.numerator < 0L { -1L } else { 1L }
  let quotient = self.numerator / self.denominator
  if self.numerator % self.denominator == 0L {
    quotient
  } else {
    quotient + (-1L + sign) / 2L
  }
}

///|
/// Truncates a rational number towards zero, returning the integer part.
///
/// Parameters:
///
/// * `self` : The rational number to truncate.
///
/// Returns the integer part of the rational number as an `Int64`.
///
/// Example:
///
/// ```moonbit
/// let a = @rational.new(7L, 3L).unwrap() // 7/3 = 2.333...
/// inspect(@rational.trunc(a), content="2")
///
/// let b = @rational.new(-7L, 3L).unwrap() // -7/3 = -2.333...
/// inspect(@rational.trunc(b), content="-2")
///
/// let c = @rational.new(5L, 2L).unwrap() // 5/2 = 2.5
/// inspect(@rational.trunc(c), content="2")
///
/// let d = @rational.new(-5L, 2L).unwrap() // -5/2 = -2.5
/// inspect(@rational.trunc(d), content="-2")
/// ```
///
pub fn T::trunc(self : T) -> Int64 {
  if self.numerator < 0L {
    -(-self.numerator / self.denominator)
  } else {
    self.numerator / self.denominator
  }
}

///|
/// Returns the fractional part of a rational number, which is the remainder
/// after removing the integer part.
///
/// Parameters:
///
/// * `self` : The rational number to get the fractional part from.
///
/// Returns a new rational number representing the fractional part of `self`.
/// This is equivalent to `self - self.trunc()`.
///
/// Example:
///
/// ```moonbit
/// let r1 = @rational.new(7L, 2L).unwrap()  // 7/2 = 3.5
/// inspect(r1.fract(), content="1/2")      // fractional part is 0.5 = 1/2
///
/// let r2 = @rational.new(-7L, 2L).unwrap() // -7/2 = -3.5  
/// inspect(r2.fract(), content="-1/2")     // fractional part is -0.5 = -1/2
///
/// let r3 = @rational.new(5L, 1L).unwrap()  // 5/1 = 5
/// inspect(r3.fract(), content="0")        // fractional part is 0
/// ```
///
pub fn fract(self : T) -> T {
  new_unchecked(self.numerator % self.denominator, self.denominator)
}

///|
/// Converts a rational number to its string representation.
///
/// Parameters:
///
/// * `self` : The rational number to convert.
/// * `logger` : The output logger to write the string representation to.
///
/// The string representation follows these rules:
///
/// * If the numerator is zero, outputs "0"
/// * If the denominator is 1 (i.e., the rational is an integer), outputs just
/// the numerator
/// * Otherwise, outputs in the format "numerator/denominator"
///
/// Example:
///
/// ```moonbit
/// let zero = @rational.new(0, 1).unwrap()
/// inspect(zero, content="0") 
///
/// let integer = @rational.new(5, 1).unwrap()
/// inspect(integer, content="5")
///
/// let fraction = @rational.new(3, 4).unwrap()
/// inspect(fraction, content="3/4") 
///
/// let negative = @rational.new(-7, 3).unwrap()
/// inspect(negative, content="-7/3") 
/// ```
///
pub impl Show for T with output(self, logger) {
  if self.numerator == 0L {
    logger.write_char('0')
  } else if self.denominator == 1L {
    self.numerator.output(logger)
  } else {
    self.numerator.output(logger)
    logger.write_char('/')
    self.denominator.output(logger)
  }
}

///|
pub impl @quickcheck.Arbitrary for T with arbitrary(size, rs) {
  let numerator : Int64 = @quickcheck.Arbitrary::arbitrary(size, rs)
  let denominator : Int64 = {
    let d : Int64 = @quickcheck.Arbitrary::arbitrary(size, rs)
    if d <= 0 {
      -d + 1
    } else {
      d
    }
  }
  new_unchecked(numerator, denominator)
}

///|
/// Checks whether the rational number represents an integer value.
///
/// Parameters:
///
/// * `self` : The rational number to check.
///
/// Returns `true` if the rational number is an integer (has a denominator of 1),
/// `false` otherwise.
///
/// Examples:
///
/// ```moonbit
/// let half = @rational.new(1L, 2L).unwrap()
/// inspect(half.is_integer(), content="false")
///
/// let whole = @rational.new(5L, 1L).unwrap()
/// inspect(whole.is_integer(), content="true")
///
/// let zero = @rational.new(0L, 1L).unwrap()
/// inspect(zero.is_integer(), content="true")
/// ```
///
pub fn is_integer(self : T) -> Bool {
  self.denominator == 1L
}

///|
pub fnalias T::(neg, abs, ceil, floor, trunc)

///|
test "op_add" {
  // 1/2 + 1/3 = 5/6
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(1L, 3L)
  let c = a + b
  assert_eq(c.numerator, 5L)
  assert_eq(c.denominator, 6L)

  // 1/2 + 1/2 = 1
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(1L, 2L)
  let c = a + b
  assert_eq(c.numerator, 1L)
  assert_eq(c.denominator, 1L)

  // 1/2 + 1/6 = 2/3
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(1L, 6L)
  let c = a + b
  assert_eq(c.numerator, 2L)

  // -1/2 + 1/2 = 0
  let a = new_unchecked(-1L, 2L)
  let b = new_unchecked(1L, 2L)
  let c = a + b
  assert_eq(c.numerator, 0L)

  // -1/2 + -1/2 = -1
  let a = new_unchecked(-1L, 2L)
  let b = new_unchecked(-1L, 2L)
  let c = a + b
  assert_eq(c.numerator, -1L)
  assert_eq(c.denominator, 1L)
}

///|
test "op_sub" {
  // 1/2 - 1/3 = 1/6
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(1L, 3L)
  let c = a - b
  assert_eq(c.numerator, 1L)
  assert_eq(c.denominator, 6L)

  // 1/2 - 1/2 = 0
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(1L, 2L)
  let c = a - b
  assert_eq(c.numerator, 0L)

  // 1/2 - 1/6 = 1/3
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(1L, 6L)
  let c = a - b
  assert_eq(c.numerator, 1L)
  assert_eq(c.denominator, 3L)

  // -1/2 - 1/2 = -1
  let a = new_unchecked(-1L, 2L)
  let b = new_unchecked(1L, 2L)
  let c = a - b
  assert_eq(c.numerator, -1L)
  assert_eq(c.denominator, 1L)

  // -1/2 - -1/2 = 0
  let a = new_unchecked(-1L, 2L)
  let b = new_unchecked(-1L, 2L)
  let c = a - b
  assert_eq(c.numerator, 0L)
}

///|
test "op_mul" {
  // 1/2 * 2/3 = 1/3
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(2L, 3L)
  let c = a * b
  assert_eq(c.numerator, 1L)
  assert_eq(c.denominator, 3L)

  // -4/3 * 3/4 = -1
  let a = new_unchecked(-4L, 3L)
  let b = new_unchecked(3L, 4L)
  let c = a * b
  assert_eq(c.numerator, -1L)
  assert_eq(c.denominator, 1L)

  // 1024/42 * 0 = 0
  let a = new_unchecked(1024L, 42L)
  let b = new_unchecked(0L, 1L)
  let c = a * b
  assert_eq(c.numerator, 0L)
  assert_eq(c.denominator, 1L)
}

///|
test "op_div" {
  // 1/2 / 2/3 = 3/4
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(2L, 3L)
  let c = a / b
  assert_eq(c.numerator, 3L)
  assert_eq(c.denominator, 4L)

  // 1/2 / -2/3 = -3/4
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(-2L, 3L)
  let c = a / b
  assert_eq(c.numerator, -3L)
  assert_eq(c.denominator, 4L)

  // 0 / 1 = 0
  let a = new_unchecked(0L, 1L)
  let b = new_unchecked(1L, 1L)
  let c = a / b
  assert_eq(c.numerator, 0L)
  assert_eq(c.denominator, 1L)
}

///|
test "reciprocal" {
  // 1/2 -> 2/1
  let a = new_unchecked(1L, 2L)
  let b = a.reciprocal()
  assert_eq(b.numerator, 2L)
  assert_eq(b.denominator, 1L)

  // -1/2 -> -2/1
  let a = new_unchecked(-1L, 2L)
  let b = a.reciprocal()
  assert_eq(b.numerator, -2L)
  assert_eq(b.denominator, 1L)
}

///|
test "neg" {
  // 1/2 -> -1/2
  let a = new_unchecked(1L, 2L)
  let b = neg(a)
  assert_eq(b.numerator, -1L)
  assert_eq(b.denominator, 2L)

  // -1/2 -> 1/2
  let a = new_unchecked(-1L, 2L)
  let b = neg(a)
  assert_eq(b.numerator, 1L)
  assert_eq(b.denominator, 2L)
}

///|
test "abs" {
  // 1/2 -> 1/2
  let a = new_unchecked(1L, 2L)
  let b = abs(a)
  assert_eq(b.numerator, 1L)
  assert_eq(b.denominator, 2L)

  // -1/2 -> 1/2
  let a = new_unchecked(-1L, 2L)
  let b = abs(a)
  assert_eq(b.numerator, 1L)
  assert_eq(b.denominator, 2L)
}

///|
test "to_double" {
  // 1/2 -> 0.5
  let a = new_unchecked(1L, 2L)
  let b = a.to_double()
  assert_eq(b, 0.5)

  // -1/2 -> -0.5
  let a = new_unchecked(-1L, 2L)
  let b = a.to_double()
  assert_eq(b, -0.5)
}

///|
test "ceil" {
  // 1/2 -> 1
  let a = new_unchecked(1L, 2L)
  let b = ceil(a)
  assert_eq(b, 1L)

  // -1/2 -> 0
  let a = new_unchecked(-1L, 2L)
  let b = ceil(a)
  assert_eq(b, 0L)

  // -2/2 -> -1
  let a = new_unchecked(-2L, 2L)
  let b = ceil(a)
  assert_eq(b, -1L)

  // 2/2 -> 1
  let a = new_unchecked(2L, 2L)
  let b = ceil(a)
  assert_eq(b, 1L)
}

///|
test "floor" {
  // 1/2 -> 0
  let a = new_unchecked(1L, 2L)
  let b = floor(a)
  assert_eq(b, 0L)

  // -1/2 -> -1
  let a = new_unchecked(-1L, 2L)
  let b = floor(a)
  assert_eq(b, -1L)

  // -2/2 -> -1
  let a = new_unchecked(-2L, 2L)
  let b = floor(a)
  assert_eq(b, -1L)

  // 2/2 -> 1
  let a = new_unchecked(2L, 2L)
  let b = floor(a)
  assert_eq(b, 1L)
}

///|
test "trunc" {
  // 1/2 -> 0
  let a = new_unchecked(1L, 2L)
  let b = trunc(a)
  assert_eq(b, 0L)

  // -1/2 -> 0
  let a = new_unchecked(-1L, 2L)
  let b = trunc(a)
  assert_eq(b, 0L)
}

///|
test "fract" {
  // 1/2 -> 1/2
  let a = new_unchecked(1L, 2L)
  let b = a.fract()
  assert_eq(b.numerator, 1L)
  assert_eq(b.denominator, 2L)

  // -1/2 -> -1/2
  let a = new_unchecked(-1L, 2L)
  let b = a.fract()
  assert_eq(b.numerator, -1L)
  assert_eq(b.denominator, 2L)

  // 3/2 -> 1/2
  let a = new_unchecked(3L, 2L)
  let b = a.fract()
  assert_eq(b.numerator, 1L)
  assert_eq(b.denominator, 2L)

  // -3/2 -> -1/2
  let a = new_unchecked(-3L, 2L)
  let b = a.fract()
  assert_eq(b.numerator, -1L)
  assert_eq(b.denominator, 2L)
}

///|
test "to_string" {
  // 1/2 -> "1/2"
  let a = new_unchecked(1L, 2L)
  let b = a.to_string()
  assert_eq(b, "1/2")

  // 4/4 -> "1"
  let a = new_unchecked(4L, 4L)
  let b = a.to_string()
  assert_eq(b, "1")

  // 0/1 -> "0"
  let a = new_unchecked(0L, 1L)
  let b = a.to_string()
  assert_eq(b, "0")
}

///|
test "is_integer" {
  // 1/2 is not an integer
  let a = new_unchecked(1L, 2L)
  assert_false(a.is_integer())

  // 1 is an integer
  let a = new_unchecked(1L, 1L)
  assert_true(a.is_integer())

  // 0 is an integer
  let a = new_unchecked(0L, 1L)
  assert_true(a.is_integer())

  // -1 is an integer
  let a = new_unchecked(-1L, 1L)
  assert_true(a.is_integer())
}

///|
test "eq and compare" {
  // 1/2 < 2/3
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(2L, 3L)
  assert_eq(a.compare(b), -1)
  assert_true(a != b)

  // -1/2 > -2/3
  let a = new_unchecked(-1L, 2L)
  let b = new_unchecked(-2L, 3L)
  assert_eq(a.compare(b), 1)
  assert_true(a != b)

  // 1/2 == 1/2
  let a = new_unchecked(1L, 2L)
  let b = new_unchecked(1L, 2L)
  assert_eq(a.compare(b), 0)
  assert_true(a == b)
}

///|
test "from_double normal case" {
  let result = try! from_double(0.5)
  assert_eq(result, new_unchecked(1L, 2L))
}

///|
test "from_double edge case" {
  let result = try? from_double(9_223_372_036_800_000_000.0)
  assert_eq(result, Ok(new_unchecked(9_223_372_036_800_000_000L, 1L)))
}

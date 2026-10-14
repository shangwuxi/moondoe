///|
pub(all) struct Generator {
  mask : Int32
  sign : Int32
} derive(Debug, Eq)

///|
pub extend Generator with @debug.Debug::{to_repr}

///|
pub extend Generator with Eq::{equal, not_equal}

///|
pub fn fraction(
  factors : Array[Factor],
  base : Int32,
  generators : Array[Generator],
) -> Plan raise DesignError {
  validate_factors(factors)
  if base < 1 || base > 12 || base + generators.length() != factors.length() {
    raise Budget("fraction base must be 1..12 and match factor/generator count")
  }
  for g in generators {
    if g.mask <= 0 || g.mask >= 1 << base || (g.sign != -1 && g.sign != 1) {
      raise Invalid(
        "generator requires nonempty base-factor mask and sign +/-1",
      )
    }
  }
  let points = []
  for row in 0..<(1 << base) {
    let point : Array[Double] = [
      for j in 0..<base => if (row & (1 << j)) == 0 { -1.0 } else { 1.0 }
    ]
    for g in generators {
      let mut x = g.sign.to_double()
      for j in 0..<base {
        if (g.mask & (1 << j)) != 0 {
          x *= point[j]
        }
      }
      point.push(x)
    }
    points.push(point)
  }
  coded_plan(factors, points)
}

///|
pub fn factorial(
  factors : Array[Factor],
  levels : Array[Int32],
  centers~ : Int32 = 0,
) -> Plan raise DesignError {
  validate_factors(factors)
  if levels.length() != factors.length() {
    raise Invalid("level count dimension mismatch")
  }
  if centers < 0 || centers > 4096 {
    raise Budget("invalid center count")
  }
  let mut count = 1
  for n in levels {
    if n < 2 || n > 64 || count > (4096 - centers) / n {
      raise Budget("factorial run budget exceeded")
    }
    count *= n
  }
  let points : Array[Array[Double]] = []
  for row in 0..<count {
    let mut value = row
    let point = Array::make(factors.length(), 0.0)
    for j = factors.length() - 1; j >= 0; j = j - 1 {
      point[j] = -1.0 +
        2.0 * (value % levels[j]).to_double() / (levels[j] - 1).to_double()
      value /= levels[j]
    }
    points.push(point)
  }
  for _ in 0..<centers {
    points.push(Array::make(factors.length(), 0.0))
  }
  coded_plan(factors, points)
}

///|
pub fn two_level(
  factors : Array[Factor],
  centers~ : Int32 = 0,
) -> Plan raise DesignError {
  factorial(factors, Array::make(factors.length(), 2), centers~)
}

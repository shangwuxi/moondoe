///|
pub fn central_composite(
  factors : Array[Factor],
  alpha : Double,
  centers~ : Int32 = 1,
) -> Plan raise DesignError {
  validate_factors(factors)
  require_number(alpha)
  if alpha <= 0.0 {
    raise Invalid("axial distance must be positive")
  }
  if factors.length() > 11 {
    raise Budget("CCD factorial core exceeds run budget")
  }
  let core = two_level(factors)
  let points = [ for r in core.runs => r.point.copy() ]
  if centers < 0 || centers > 4096 - points.length() - 2 * factors.length() {
    raise Budget("CCD run budget exceeded")
  }
  for j in 0..<factors.length() {
    for sign in [-1.0, 1.0] {
      let row = Array::make(factors.length(), 0.0)
      row[j] = sign * alpha
      points.push(row)
    }
  }
  for _ in 0..<centers {
    points.push(Array::make(factors.length(), 0.0))
  }
  coded_plan(factors, points)
}

///|
pub fn box_behnken(
  factors : Array[Factor],
  centers~ : Int32 = 1,
) -> Plan raise DesignError {
  validate_factors(factors)
  let k = factors.length()
  if k < 3 {
    raise Invalid("Box-Behnken requires at least three factors")
  }
  if centers < 0 || centers > 4096 - 2 * k * (k - 1) {
    raise Budget("BBD run budget exceeded")
  }
  let points = []
  for i in 0..<k {
    for j in (i + 1)..<k {
      for a in [-1.0, 1.0] {
        for b in [-1.0, 1.0] {
          let point = Array::make(k, 0.0)
          point[i] = a
          point[j] = b
          points.push(point)
        }
      }
    }
  }
  for _ in 0..<centers {
    points.push(Array::make(k, 0.0))
  }
  coded_plan(factors, points)
}

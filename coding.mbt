///|
// Recover the low part of a bounded sum (all operands here are <= 4e100).
// This keeps the exact midpoint correction when the rounded sum loses a bit.
fn coding_sum(a : Double, b : Double) -> (Double, Double) {
  let sum = a + b
  let part = sum - a
  (sum, a - (sum - part) + (b - part))
}

///|
pub fn decode(f : Factor, coded : Double) -> Double raise DesignError {
  ignore(factor(f.name, f.low, f.high))
  require_number(coded)
  if coded == -1.0 {
    return f.low
  }
  if coded == 1.0 {
    return f.high
  }
  let span = f.high - f.low
  let value = if span < 2.2250738585072014e-308 || coded < -0.5 {
    // Do not halve a subnormal width: its half may round to zero.
    f.low + (coded + 1.0) / 2.0 * span
  } else if coded > 0.5 {
    f.high + (coded - 1.0) / 2.0 * span
  } else {
    // Avoid coded + 1, which erases small signed coordinates at the center.
    let (midpoint, midpoint_error) = coding_sum(f.low, f.high)
    let (width, width_error) = coding_sum(f.high, -f.low)
    let (sum, error) = coding_sum(midpoint, coded * width)
    (sum + (error + midpoint_error + coded * width_error)) / 2.0
  }
  require_number(value)
  value
}

///|
pub fn encode(f : Factor, actual : Double) -> Double raise DesignError {
  ignore(factor(f.name, f.low, f.high))
  require_number(actual)
  if actual == f.low {
    return -1.0
  }
  if actual == f.high {
    return 1.0
  }
  // Form 2*actual - low - high with the midpoint's rounding correction.
  // Subtracting the low endpoint first can collapse distinct centered points.
  let (midpoint, midpoint_error) = coding_sum(f.low, f.high)
  let (offset, offset_error) = coding_sum(2.0 * actual, -midpoint)
  let value = (offset + (offset_error - midpoint_error)) / (f.high - f.low)
  require_number(value)
  value
}

///|
pub fn actual_points(p : Plan) -> Array[Array[Double]] raise DesignError {
  validate_plan(p)
  [
    for r in p.runs => [ for j, x in r.point => decode(p.factors[j], x) ]
  ]
}

///|
pub fn physical_plan(
  factors : Array[Factor],
  points : Array[Array[Double]],
) -> Plan raise DesignError {
  validate_factors(factors)
  if points.length() == 0 || points.length() > 4096 {
    raise Budget("run count must be 1..4096")
  }
  let rows : Array[Array[Double]] = []
  for point in points {
    if point.length() != factors.length() {
      raise Invalid("point dimension mismatch")
    }
    rows.push([ for j, x in point => encode(factors[j], x) ])
  }
  coded_plan(factors, rows)
}

///|
pub fn within_bounds(p : Plan) -> Array[String] raise DesignError {
  validate_plan(p)
  let outside = []
  for r in p.runs {
    if r.point.any(fn(x) { x < -1.0 || x > 1.0 }) {
      outside.push(r.id)
    }
  }
  outside
}

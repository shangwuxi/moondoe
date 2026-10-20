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
  let value = f.low + (coded + 1.0) / 2.0 * (f.high - f.low)
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
  let value = (actual - f.low) / (f.high - f.low) * 2.0 - 1.0
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

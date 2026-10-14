///|
pub(all) struct LinearConstraint {
  name : String
  coefficients : Array[Double]
  upper : Double
} derive(Debug, Eq)

///|
pub extend LinearConstraint with @debug.Debug::{to_repr}

///|
pub extend LinearConstraint with Eq::{equal, not_equal}

///|
pub fn filter_candidates(
  p : Plan,
  constraints : Array[LinearConstraint],
  tol? : Double = 1.0e-10,
) -> Plan raise DesignError {
  tolerance(tol)
  validate_plan(p)
  if constraints.length() > 64 {
    raise Budget("constraint count exceeds 64")
  }
  for c in constraints {
    if c.name.length() == 0 || c.coefficients.length() != p.factors.length() {
      raise Invalid("constraint name/dimension mismatch")
    }
    require_number(c.upper)
    for x in c.coefficients {
      require_number(x)
    }
  }
  let runs = []
  for r in p.runs {
    let mut passes = true
    for c in constraints {
      let mut value = 0.0
      for j, x in r.point {
        value += c.coefficients[j] * x
      }
      require_number(value)
      if value > c.upper + tol {
        passes = false
        break
      }
    }
    if passes {
      runs.push(r)
    }
  }
  if runs.length() == 0 {
    raise Invalid("no feasible candidate runs")
  }
  plan(p.factors, runs)
}

///|
pub fn filter_points(
  p : Plan,
  predicate : (Array[Double]) -> Bool,
) -> Plan raise DesignError {
  validate_plan(p)
  let runs = []
  for r in p.runs {
    if predicate(r.point.copy()) {
      runs.push(r)
    }
  }
  if runs.length() == 0 {
    raise Invalid("predicate removed all candidates")
  }
  plan(p.factors, runs)
}

///|
pub fn unique_points(p : Plan) -> Plan raise DesignError {
  validate_plan(p)
  let runs : Array[Run] = []
  for r in p.runs {
    if !runs.any(fn(other) { other.point == r.point }) {
      runs.push(r)
    }
  }
  plan(p.factors, runs)
}

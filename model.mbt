///|
pub suberror DesignError {
  Invalid(String)
  Budget(String)
  Singular(String)
} derive(Debug, Eq)

///|
pub(all) struct Factor {
  name : String
  low : Double
  high : Double
} derive(Debug, Eq)

///|
pub(all) struct Run {
  id : String
  block : Int
  point : Array[Double]
} derive(Debug, Eq)

///|
pub(all) struct Plan {
  factors : Array[Factor]
  runs : Array[Run]
} derive(Debug, Eq)

///|
fn finite(x : Double) -> Bool {
  x == x && x.abs() <= 1.0e100
}

///|
fn require_number(x : Double) -> Unit raise DesignError {
  if !finite(x) {
    raise Invalid("number must be finite with magnitude <= 1e100")
  }
}

///|
pub fn factor(
  name : String,
  low : Double,
  high : Double,
) -> Factor raise DesignError {
  require_number(low)
  require_number(high)
  if name.trim().length() == 0 || name.length() > 128 {
    raise Invalid("factor name must contain 1..128 characters")
  }
  if high <= low {
    raise Invalid("factor bounds must strictly increase")
  }
  { name, low, high, }
}

///|
fn validate_factors(factors : Array[Factor]) -> Unit raise DesignError {
  if factors.length() == 0 || factors.length() > 16 {
    raise Budget("factor count must be 1..16")
  }
  for i, f in factors {
    ignore(factor(f.name, f.low, f.high))
    for j in 0..<i {
      if factors[j].name == f.name {
        raise Invalid("duplicate factor name")
      }
    }
  }
}

///|
pub fn plan(
  factors : Array[Factor],
  runs : Array[Run],
) -> Plan raise DesignError {
  validate_factors(factors)
  if runs.length() == 0 || runs.length() > 4096 {
    raise Budget("run count must be 1..4096")
  }
  for i, r in runs {
    if r.id.length() == 0 || r.id.length() > 128 || r.block < 0 {
      raise Invalid("invalid run id or block")
    }
    if r.point.length() != factors.length() {
      raise Invalid("run dimension mismatch")
    }
    for x in r.point {
      require_number(x)
    }
    for j in 0..<i {
      if runs[j].id == r.id {
        raise Invalid("duplicate run id")
      }
    }
  }
  {
    factors: factors.copy(),
    runs: [
      for r in runs => { ..r, point: r.point.copy(), }
    ],
  }
}

///|
pub fn coded_plan(
  factors : Array[Factor],
  points : Array[Array[Double]],
) -> Plan raise DesignError {
  plan(
    factors,
    [
      for i, point in points => { id: "r\{i + 1}", block: 0, point, }
    ],
  )
}

///|
pub fn validate_plan(p : Plan) -> Unit raise DesignError {
  ignore(plan(p.factors, p.runs))
}

///|
pub extend DesignError with @debug.Debug::{to_repr}

///|
pub extend DesignError with Eq::{equal, not_equal}

///|
pub extend Factor with @debug.Debug::{to_repr}

///|
pub extend Factor with Eq::{equal, not_equal}

///|
pub extend Run with @debug.Debug::{to_repr}

///|
pub extend Run with Eq::{equal, not_equal}

///|
pub extend Plan with @debug.Debug::{to_repr}

///|
pub extend Plan with Eq::{equal, not_equal}

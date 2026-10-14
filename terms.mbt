///|
pub(all) struct Term {
  name : String
  powers : Array[Int]
} derive(Debug, Eq)

///|
pub extend Term with @debug.Debug::{to_repr}

///|
pub extend Term with Eq::{equal, not_equal}

///|
pub fn terms(
  factors : Array[Factor],
  order : Int,
) -> Array[Term] raise DesignError {
  validate_factors(factors)
  if order < 0 || order > 2 {
    raise Invalid("model order must be 0, 1 or 2")
  }
  let k = factors.length()
  let result : Array[Term] = [{ name: "Intercept", powers: Array::make(k, 0), }]
  if order >= 1 {
    for j in 0..<k {
      let powers = Array::make(k, 0)
      powers[j] = 1
      result.push({ name: factors[j].name, powers, })
    }
  }
  if order == 2 {
    for i in 0..<k {
      for j in (i + 1)..<k {
        let powers = Array::make(k, 0)
        powers[i] = 1
        powers[j] = 1
        result.push({ name: "\{factors[i].name}*\{factors[j].name}", powers, })
      }
    }
    for j in 0..<k {
      let powers = Array::make(k, 0)
      powers[j] = 2
      result.push({ name: "\{factors[j].name}^2", powers, })
    }
  }
  validate_terms(result, k)
  result
}

///|
fn validate_terms(model : Array[Term], k : Int) -> Unit raise DesignError {
  if model.length() == 0 || model.length() > 128 {
    raise Budget("term count must be 1..128")
  }
  for i, t in model {
    if t.name.length() == 0 || t.name.length() > 256 || t.powers.length() != k {
      raise Invalid("invalid term name/dimension")
    }
    let mut degree = 0
    for n in t.powers {
      if n < 0 || n > 8 {
        raise Invalid("powers must be 0..8")
      }
      degree += n
    }
    if degree > 16 {
      raise Budget("term total degree exceeds 16")
    }
    for j in 0..<i {
      if t.name == model[j].name || t.powers == model[j].powers {
        raise Invalid("duplicate model term")
      }
    }
  }
}

///|
pub fn evaluate_terms(
  point : Array[Double],
  model : Array[Term],
) -> Array[Double] raise DesignError {
  if point.length() == 0 || point.length() > 16 {
    raise Budget("point dimension must be 1..16")
  }
  validate_terms(model, point.length())
  for x in point {
    require_number(x)
  }
  let result = []
  for t in model {
    let mut value = 1.0
    for j, n in t.powers {
      for _ in 0..<n {
        value *= point[j]
        require_number(value)
      }
    }
    result.push(value)
  }
  result
}

///|
pub fn design_matrix(
  p : Plan,
  model : Array[Term],
) -> Array[Array[Double]] raise DesignError {
  validate_plan(p)
  validate_terms(model, p.factors.length())
  [
    for r in p.runs => evaluate_terms(r.point, model)
  ]
}

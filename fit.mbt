///|
pub(all) struct Fit {
  coefficients : Array[Double]
  fitted : Array[Double]
  residuals : Array[Double]
  sse : Double
  dof : Int
  variance : Double?
} derive(Debug, Eq)

///|
pub extend Fit with @debug.Debug::{to_repr}

///|
pub extend Fit with Eq::{equal, not_equal}

///|
pub fn least_squares(
  a : Array[Array[Double]],
  responses : Array[Double],
  weights? : Array[Double] = [],
  tol? : Double = 1.0e-10,
) -> Fit raise DesignError {
  tolerance(tol)
  let (n, p) = matrix_shape(a)
  if p > 64 || n < p {
    raise Budget("least squares requires rows >= columns and <=64 terms")
  }
  if responses.length() != n || (weights.length() != 0 && weights.length() != n) {
    raise Invalid("response/weight count mismatch")
  }
  let work = zeros(n, p)
  let y = Array::make(n, 0.0)
  for i in 0..<n {
    require_number(responses[i])
    let w = if weights.length() == 0 { 1.0 } else { weights[i] }
    require_number(w)
    if w <= 0.0 {
      raise Invalid("weights must be positive")
    }
    let root = w.sqrt()
    y[i] = responses[i] * root
    require_number(y[i])
    for j in 0..<p {
      work[i][j] = a[i][j] * root
      require_number(work[i][j])
    }
  }
  let scales = Array::make(p, 0.0)
  for j in 0..<p {
    for i in 0..<n {
      if work[i][j].abs() > scales[j] {
        scales[j] = work[i][j].abs()
      }
    }
    if scales[j] == 0.0 {
      raise Singular("zero model column")
    }
    for i in 0..<n {
      work[i][j] /= scales[j]
    }
  }
  let permutation = [ for j in 0..<p => j ]
  let r = zeros(p, p)
  let qty = Array::make(p, 0.0)
  for k in 0..<p {
    let mut pivot = k
    let mut best = -1.0
    for j in k..<p {
      let mut norm = 0.0
      for i in 0..<n {
        norm += work[i][j] * work[i][j]
      }
      if norm > best {
        best = norm
        pivot = j
      }
    }
    if best <= tol * tol {
      raise Singular("model is not identifiable at requested tolerance")
    }
    if pivot != k {
      for i in 0..<n {
        let value = work[i][k]
        work[i][k] = work[i][pivot]
        work[i][pivot] = value
      }
      for i in 0..<k {
        let value = r[i][k]
        r[i][k] = r[i][pivot]
        r[i][pivot] = value
      }
      let index = permutation[k]
      permutation[k] = permutation[pivot]
      permutation[pivot] = index
    }
    r[k][k] = best.sqrt()
    for i in 0..<n {
      work[i][k] /= r[k][k]
      qty[k] += work[i][k] * y[i]
    }
    for j in (k + 1)..<p {
      // Two passes of modified Gram-Schmidt reduce loss of orthogonality.
      for _ in 0..<2 {
        let mut projection = 0.0
        for i in 0..<n {
          projection += work[i][k] * work[i][j]
        }
        r[k][j] += projection
        for i in 0..<n {
          work[i][j] -= projection * work[i][k]
        }
      }
    }
  }
  let solution = Array::make(p, 0.0)
  for k = p - 1; k >= 0; k = k - 1 {
    let mut value = qty[k]
    for j in (k + 1)..<p {
      value -= r[k][j] * solution[j]
    }
    solution[k] = value / r[k][k]
  }
  let coefficients = Array::make(p, 0.0)
  for j in 0..<p {
    coefficients[permutation[j]] = solution[j] / scales[permutation[j]]
    require_number(coefficients[permutation[j]])
  }
  let fitted = Array::make(n, 0.0)
  let residuals = Array::make(n, 0.0)
  let mut sse = 0.0
  for i in 0..<n {
    for j in 0..<p {
      fitted[i] += a[i][j] * coefficients[j]
    }
    residuals[i] = responses[i] - fitted[i]
    let w = if weights.length() == 0 { 1.0 } else { weights[i] }
    sse += w * residuals[i] * residuals[i]
    require_number(fitted[i])
    require_number(residuals[i])
  }
  require_number(sse)
  let dof = n - p
  {
    coefficients,
    fitted,
    residuals,
    sse,
    dof,
    variance: if dof > 0 {
      Some(sse / dof.to_double())
    } else {
      None
    },
  }
}

///|
pub fn fit_plan(
  p : Plan,
  model : Array[Term],
  responses : Array[Double],
) -> Fit raise DesignError {
  least_squares(design_matrix(p, model), responses)
}

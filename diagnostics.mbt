///|
pub(all) struct AliasPair {
  left : String
  right : String
  correlation : Double
} derive(Debug, Eq)

///|
pub extend AliasPair with @debug.Debug::{to_repr}

///|
pub extend AliasPair with Eq::{equal, not_equal}

///|
pub(all) struct Diagnostics {
  runs : Int32
  terms : Int32
  rank : Int32
  residual_dof : Int32
  estimable : Bool
  zero_columns : Array[String]
  exact_aliases : Array[AliasPair]
  max_abs_correlation : Double
  log_determinant : Double?
} derive(Debug, Eq)

///|
pub extend Diagnostics with @debug.Debug::{to_repr}

///|
pub extend Diagnostics with Eq::{equal, not_equal}

///|
pub fn diagnose(
  p : Plan,
  model : Array[Term],
  tol~ : Double = 1.0e-10,
) -> Diagnostics raise DesignError {
  tolerance(tol)
  let a = design_matrix(p, model)
  let (_, k) = matrix_shape(a)
  let norms = Array::make(k, 0.0)
  let scaled = [ for row in a => row.copy() ]
  let zero_columns = []
  for j in 0..<k {
    let mut scale = 0.0
    for row in a {
      if row[j].abs() > scale {
        scale = row[j].abs()
      }
    }
    if scale == 0.0 {
      zero_columns.push(model[j].name)
    } else {
      for i in 0..<a.length() {
        scaled[i][j] /= scale
        norms[j] += scaled[i][j] * scaled[i][j]
      }
    }
  }
  let exact_aliases = []
  let mut max_abs_correlation = 0.0
  for i in 0..<k {
    for j in (i + 1)..<k {
      if norms[i] == 0.0 || norms[j] == 0.0 {
        continue
      }
      let mut product = 0.0
      for row in scaled {
        product += row[i] * row[j]
      }
      let correlation = product / norms[i].sqrt() / norms[j].sqrt()
      let absolute = correlation.abs()
      if absolute > max_abs_correlation {
        max_abs_correlation = absolute
      }
      if (1.0 - absolute).abs() <= tol {
        exact_aliases.push({
          left: model[i].name,
          right: model[j].name,
          correlation,
        })
      }
    }
  }
  let rank = matrix_rank(a, tol~)
  {
    runs: a.length(),
    terms: k,
    rank,
    residual_dof: a.length() - rank,
    estimable: rank == k,
    zero_columns,
    exact_aliases,
    max_abs_correlation,
    log_determinant: log_determinant(information(a), tol~),
  }
}

///|
pub fn alias_matrix(
  fitted : Array[Array[Double]],
  omitted : Array[Array[Double]],
  tol~ : Double = 1.0e-10,
) -> Array[Array[Double]] raise DesignError {
  let (n, p) = matrix_shape(fitted)
  let (m, q) = matrix_shape(omitted)
  if n != m {
    raise Invalid("alias matrix run counts must match")
  }
  let result = zeros(p, q)
  for j in 0..<q {
    let fit = least_squares(fitted, [ for row in omitted => row[j] ], tol~)
    for i in 0..<p {
      result[i][j] = fit.coefficients[i]
    }
  }
  result
}

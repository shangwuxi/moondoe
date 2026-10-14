///|
pub fn predict(
  coefficients : Array[Double],
  model : Array[Term],
  point : Array[Double],
) -> Double raise DesignError {
  let row = evaluate_terms(point, model)
  if coefficients.length() != row.length() {
    raise Invalid("coefficient count mismatch")
  }
  let mut value = 0.0
  for j, x in row {
    require_number(coefficients[j])
    value += x * coefficients[j]
  }
  require_number(value)
  value
}

///|
pub fn covariance(
  a : Array[Array[Double]],
  variance : Double,
  weights? : Array[Double] = [],
) -> Array[Array[Double]] raise DesignError {
  require_number(variance)
  if variance < 0.0 {
    raise Invalid("variance must be nonnegative")
  }
  let result = inverse(information(a, weights~))
  for row in result {
    for j in 0..<row.length() {
      row[j] *= variance
      require_number(row[j])
    }
  }
  result
}

///|
pub fn prediction_variance(
  row : Array[Double],
  covariance : Array[Array[Double]],
) -> Double raise DesignError {
  let (n, p) = matrix_shape(covariance)
  if n != p || row.length() != n {
    raise Invalid("prediction covariance shape mismatch")
  }
  for x in row {
    require_number(x)
  }
  let mut value = 0.0
  for i in 0..<n {
    for j in 0..<n {
      value += row[i] * covariance[i][j] * row[j]
    }
  }
  require_number(value)
  if value < -1.0e-10 {
    raise Invalid("negative quadratic variance; covariance not PSD")
  }
  if value < 0.0 {
    0.0
  } else {
    value
  }
}

///|
pub fn leverage(a : Array[Array[Double]]) -> Array[Double] raise DesignError {
  let c = covariance(a, 1.0)
  [
    for row in a => prediction_variance(row, c)
  ]
}

///|
pub fn variance_profile(
  p : Plan,
  model : Array[Term],
  points : Array[Array[Double]],
) -> Array[Double] raise DesignError {
  if points.length() > 4096 {
    raise Budget("prediction grid exceeds 4096 points")
  }
  let c = covariance(design_matrix(p, model), 1.0)
  [
    for point in points => prediction_variance(evaluate_terms(point, model), c)
  ]
}

///|
pub fn gradient(
  coefficients : Array[Double],
  model : Array[Term],
  point : Array[Double],
) -> Array[Double] raise DesignError {
  validate_terms(model, point.length())
  if coefficients.length() != model.length() {
    raise Invalid("gradient coefficient count mismatch")
  }
  for x in point {
    require_number(x)
  }
  let values = Array::make(point.length(), 0.0)
  for i, t in model {
    require_number(coefficients[i])
    for axis in 0..<point.length() {
      if t.powers[axis] == 0 {
        continue
      }
      let mut value = coefficients[i] * t.powers[axis].to_double()
      for j, n in t.powers {
        let exponent = if j == axis { n - 1 } else { n }
        for _ in 0..<exponent {
          value *= point[j]
        }
      }
      values[axis] += value
    }
  }
  for v in values {
    require_number(v)
  }
  values
}

///|
pub fn inverse(
  a : Array[Array[Double]],
  tol? : Double = 1.0e-10,
) -> Array[Array[Double]] raise DesignError {
  tolerance(tol)
  let (n, p) = matrix_shape(a)
  if n != p {
    raise Invalid("inverse requires square matrix")
  }
  let work = [ for row in a => row.copy() ]
  let result = zeros(n, n)
  for i in 0..<n {
    let mut scale = 0.0
    for x in work[i] {
      if x.abs() > scale {
        scale = x.abs()
      }
    }
    if scale == 0.0 {
      raise Singular("zero matrix row")
    }
    for j in 0..<n {
      work[i][j] /= scale
    }
    result[i][i] = 1.0 / scale
  }
  for col in 0..<n {
    let mut pivot = col
    for i in (col + 1)..<n {
      if work[i][col].abs() > work[pivot][col].abs() {
        pivot = i
      }
    }
    if work[pivot][col].abs() <= tol {
      raise Singular("matrix pivot below tolerance")
    }
    let row = work[col]
    work[col] = work[pivot]
    work[pivot] = row
    let right = result[col]
    result[col] = result[pivot]
    result[pivot] = right
    let value = work[col][col]
    for j in 0..<n {
      work[col][j] /= value
      result[col][j] /= value
    }
    for i in 0..<n {
      if i != col {
        let scale = work[i][col]
        for j in 0..<n {
          work[i][j] -= scale * work[col][j]
          result[i][j] -= scale * result[col][j]
        }
      }
    }
  }
  for row in result {
    for x in row {
      require_number(x)
    }
  }
  result
}

///|
pub fn log_determinant(
  a : Array[Array[Double]],
  tol? : Double = 1.0e-10,
) -> Double? raise DesignError {
  tolerance(tol)
  let (n, p) = matrix_shape(a)
  if n != p {
    raise Invalid("positive determinant requires square matrix")
  }
  let scales = Array::make(n, 0.0)
  for i in 0..<n {
    if a[i][i] <= 0.0 {
      return None
    }
    scales[i] = a[i][i].sqrt()
    for j in 0..<i {
      let delta = (a[i][j] - a[j][i]).abs()
      let magnitude = a[i][j].abs() + a[j][i].abs() + 1.0
      if delta > tol * magnitude {
        raise Invalid("matrix must be symmetric")
      }
    }
  }
  let l = zeros(n, n)
  let mut value = 0.0
  for i in 0..<n {
    for j in 0..<(i + 1) {
      let mut sum = a[i][j] / scales[i] / scales[j]
      for k in 0..<j {
        sum -= l[i][k] * l[j][k]
      }
      if i == j {
        if sum <= tol {
          return None
        }
        l[i][j] = sum.sqrt()
        value += 2.0 * (@math.ln(scales[i]) + @math.ln(l[i][j]))
      } else {
        l[i][j] = sum / l[j][j]
      }
    }
  }
  require_number(value)
  Some(value)
}

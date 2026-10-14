///|
fn matrix_shape(a : Array[Array[Double]]) -> (Int, Int) raise DesignError {
  if a.length() == 0 || a.length() > 4096 {
    raise Budget("matrix row count must be 1..4096")
  }
  let cols = a[0].length()
  if cols == 0 || cols > 128 {
    raise Budget("matrix column count must be 1..128")
  }
  for row in a {
    if row.length() != cols {
      raise Invalid("ragged matrix")
    }
    for x in row {
      require_number(x)
    }
  }
  (a.length(), cols)
}

///|
fn zeros(rows : Int, cols : Int) -> Array[Array[Double]] {
  [
    for _ in 0..<rows => Array::make(cols, 0.0)
  ]
}

///|
fn tolerance(tol : Double) -> Unit raise DesignError {
  if !finite(tol) || tol < 1.0e-14 || tol > 0.01 {
    raise Invalid("relative tolerance must be 1e-14..0.01")
  }
}

///|
pub fn transpose(
  a : Array[Array[Double]],
) -> Array[Array[Double]] raise DesignError {
  let (n, p) = matrix_shape(a)
  let result = zeros(p, n)
  for i in 0..<n {
    for j in 0..<p {
      result[j][i] = a[i][j]
    }
  }
  result
}

///|
pub fn multiply(
  a : Array[Array[Double]],
  b : Array[Array[Double]],
) -> Array[Array[Double]] raise DesignError {
  let (n, p) = matrix_shape(a)
  let (m, q) = matrix_shape(b)
  if p != m {
    raise Invalid("matrix multiplication shape mismatch")
  }
  if q > 128 {
    raise Budget("product exceeds column budget")
  }
  let result = zeros(n, q)
  for i in 0..<n {
    for j in 0..<q {
      let mut value = 0.0
      for k in 0..<p {
        value += a[i][k] * b[k][j]
      }
      require_number(value)
      result[i][j] = value
    }
  }
  result
}

///|
pub fn matrix_rank(
  a : Array[Array[Double]],
  tol? : Double = 1.0e-10,
) -> Int raise DesignError {
  tolerance(tol)
  let (n, p) = matrix_shape(a)
  let work = [ for row in a => row.copy() ]
  // Equilibrate columns: the threshold must not depend on a user's physical units.
  for j in 0..<p {
    let mut scale = 0.0
    for i in 0..<n {
      if work[i][j].abs() > scale {
        scale = work[i][j].abs()
      }
    }
    if scale > 0.0 {
      for i in 0..<n {
        work[i][j] /= scale
      }
    }
  }
  let mut rank = 0
  for col in 0..<p {
    if rank == n {
      break
    }
    let mut pivot = rank
    for i in (rank + 1)..<n {
      if work[i][col].abs() > work[pivot][col].abs() {
        pivot = i
      }
    }
    if work[pivot][col].abs() <= tol {
      continue
    }
    let swap = work[rank]
    work[rank] = work[pivot]
    work[pivot] = swap
    for i in (rank + 1)..<n {
      let factor = work[i][col] / work[rank][col]
      work[i][col] = 0.0
      for j in (col + 1)..<p {
        work[i][j] -= factor * work[rank][j]
      }
    }
    rank += 1
  }
  rank
}

///|
pub fn information(
  a : Array[Array[Double]],
  weights? : Array[Double] = [],
) -> Array[Array[Double]] raise DesignError {
  let (n, p) = matrix_shape(a)
  if weights.length() != 0 && weights.length() != n {
    raise Invalid("weight count mismatch")
  }
  let result = zeros(p, p)
  for i in 0..<n {
    let w = if weights.length() == 0 { 1.0 } else { weights[i] }
    require_number(w)
    if w <= 0.0 {
      raise Invalid("weights must be strictly positive")
    }
    for j in 0..<p {
      for k in 0..<(j + 1) {
        result[j][k] += w * a[i][j] * a[i][k]
      }
    }
  }
  for j in 0..<p {
    for k in 0..<(j + 1) {
      require_number(result[j][k])
      result[k][j] = result[j][k]
    }
  }
  result
}

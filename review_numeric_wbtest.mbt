///|
fn round2_invalid(action : () -> Unit raise DesignError) -> Bool {
  try {
    action()
    false
  } catch {
    DesignError::Invalid(_) => true
    _ => false
  }
}

///|
test "REVIEW R06 logdet symmetry is independent of units" {
  for scale in [1.0e-200, 1.0e-20, 1.0, 1.0e40] {
    assert_true(
      round2_invalid(fn() raise DesignError {
        ignore(log_determinant([[scale, scale * 0.5], [scale * 0.25, scale]]))
      }),
    )
    let value = log_determinant([[scale, scale * 0.5], [scale * 0.5, scale]])
    let expected = 2.0 * @math.ln(scale) + @math.ln(0.75)
    assert_true(value is Some(v) && (v - expected).abs() < 1.0e-10)
  }
}

///|
test "REVIEW R06 nonsymmetric matrix does not bypass validation at zero diagonal" {
  assert_true(
    round2_invalid(fn() raise DesignError {
      ignore(log_determinant([[0.0, 1.0], [0.0, 1.0]]))
    }),
  )
  assert_eq(log_determinant([[0.0, 0.0], [0.0, 1.0]]), None)
}

///|
test "REVIEW R07 standardized residuals preserve response scaling" {
  let a = [[1.0, -1.0], [1.0, 0.0], [1.0, 1.0]]
  for scale in [1.0, 1.0e-8, 1.0e-80, 1.0e-150, 1.0e40] {
    let f = least_squares(a, [scale, 0.0, scale])
    let r = standardized_residuals(a, f)
    for i in 0..<3 {
      let expected = if i == 1 { -1.0 } else { 1.0 }
      assert_true(r[i] is Some(v) && (v - expected).abs() < 1.0e-10)
    }
  }
}

///|
test "REVIEW R08 F ratio respects the finite result budget" {
  let fs = [factor("x", -1.0, 1.0)]
  let p = coded_plan(fs, [[-1.0], [-1.0], [0.0], [0.0], [1.0], [1.0]])
  for noise in [1.0e-60, 1.0e-160] {
    assert_true(
      round2_invalid(fn() raise DesignError {
        ignore(
          partition_error(p, terms(fs, 1), [0.0, noise, 1.0, 1.0, 0.0, 0.0]),
        )
      }),
    )
  }
}

///|
test "REVIEW R09 negative prediction variance is not hidden by units" {
  for scale in [1.0e-200, 1.0e-20, 1.0, 1.0e50] {
    assert_true(
      round2_invalid(fn() raise DesignError {
        ignore(prediction_variance([1.0], [[-scale]]))
      }),
    )
    assert_eq(prediction_variance([1.0], [[scale]]), scale)
  }
  assert_eq(prediction_variance([1.0], [[0.0]]), 0.0)
}

///|
test "REVIEW R09 cancellation tolerance is relative to quadratic contributions" {
  for scale in [1.0, 1.0e40] {
    assert_eq(
      prediction_variance([1.0, -1.0], [
        [scale, scale],
        [scale, scale * (1.0 - 1.0e-15)],
      ]),
      0.0,
    )
  }
}

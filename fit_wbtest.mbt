///|
test "pivoted QR recovers coefficients and weighted residuals" {
  let a = [[1.0, -1.0], [1.0, 0.0], [1.0, 1.0]]
  let f = least_squares(a, [1.0, 3.0, 5.0], weights=[1.0, 2.0, 1.0])
  assert_true((f.coefficients[0] - 3.0).abs() < 1.0e-12)
  assert_true((f.coefficients[1] - 2.0).abs() < 1.0e-12)
  assert_true(f.sse < 1.0e-20)
  assert_eq(f.dof, 1)
  assert_true(
    rejected(fn() raise DesignError {
      ignore(least_squares([[1.0, 1.0], [1.0, 1.0]], [1.0, 2.0]))
    }),
  )
}

///|
test "quadratic analytical recovery" {
  let fs = [factor("x", -1.0, 1.0), factor("y", -1.0, 1.0)]
  let p = central_composite(fs, 1.5, centers=2)
  let ys = [
    for r in p.runs => {
      2.0 +
      3.0 * r.point[0] -
      r.point[1] +
      4.0 * r.point[0] * r.point[1] +
      r.point[0] * r.point[0] -
      2.0 * r.point[1] * r.point[1]
    }
  ]
  let f = fit_plan(p, terms(fs, 2), ys)
  for j, b in [2.0, 3.0, -1.0, 4.0, 1.0, -2.0] {
    assert_true((f.coefficients[j] - b).abs() < 1.0e-10)
  }
}

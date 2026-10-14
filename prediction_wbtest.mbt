///|
test "leverage trace and quadratic gradient" {
  let a = [[1.0, -1.0], [1.0, 0.0], [1.0, 1.0]]
  let h = leverage(a)
  assert_true((h[0] + h[1] + h[2] - 2.0).abs() < 1.0e-12)
  assert_true(
    (prediction_variance([1.0, 0.0], covariance(a, 3.0)) - 1.0).abs() < 1.0e-12,
  )
  let fs = [factor("x", -1.0, 1.0)]
  let m = terms(fs, 2)
  assert_eq(predict([2.0, 3.0, 4.0], m, [2.0]), 24.0)
  assert_eq(gradient([2.0, 3.0, 4.0], m, [2.0]), [19.0])
}

///|
test "inverse identity and SPD log determinant" {
  let a = [[4.0, 1.0], [1.0, 3.0]]
  let unit = multiply(a, inverse(a))
  for i in 0..<2 {
    for j in 0..<2 {
      assert_true(
        (unit[i][j] - (if i == j { 1.0 } else { 0.0 })).abs() < 1.0e-12,
      )
    }
  }
  match log_determinant(a) {
    Some(x) => assert_true((x - @math.ln(11.0)).abs() < 1.0e-12)
    None => fail("expected SPD")
  }
  assert_eq(log_determinant([[1.0, 1.0], [1.0, 1.0]]), None)
  assert_true(
    rejected(fn() raise DesignError {
      ignore(inverse([[1.0, 1.0], [1.0, 1.0]]))
    }),
  )
}

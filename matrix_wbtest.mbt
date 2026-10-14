///|
test "rank scale invariance and information symmetry" {
  assert_eq(matrix_rank([[1.0, 2.0], [2.0, 4.0]]), 1)
  assert_eq(matrix_rank([[1.0e-20, 0.0], [0.0, 1.0e20]]), 2)
  let a = [[1.0, -1.0], [1.0, 1.0]]
  assert_eq(information(a), [[2.0, 0.0], [0.0, 2.0]])
  assert_eq(multiply(transpose(a), a), information(a))
  assert_true(
    rejected(fn() raise DesignError { ignore(matrix_rank([[1.0], []])) }),
  )
}

///|
test "quadratic model term ordering and rejection" {
  let fs = [factor("x", -1.0, 1.0), factor("y", -1.0, 1.0)]
  let m = terms(fs, 2)
  assert_eq(m.length(), 6)
  assert_eq(evaluate_terms([2.0, 3.0], m), [1.0, 2.0, 3.0, 6.0, 4.0, 9.0])
  assert_eq(design_matrix(two_level(fs), terms(fs, 1)).length(), 4)
  assert_true(
    rejected(fn() raise DesignError { ignore(evaluate_terms([1.0], m)) }),
  )
}

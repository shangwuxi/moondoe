///|
test "D optimal recovers endpoints and monotone score" {
  let fs = [factor("x", -1.0, 1.0)]
  let candidates = factorial(fs, [5])
  let result = d_optimal(candidates, terms(fs, 1), 2)
  assert_eq(result.indices, [4, 0])
  assert_true((result.final_logdet - @math.ln(4.0)).abs() < 1.0e-12)
  assert_true(result.converged)
  for i in 1..<result.improvements.length() {
    assert_true(result.improvements[i] > result.improvements[i - 1])
  }
  assert_true(
    rejected(fn() raise DesignError {
      ignore(d_optimal(candidates, terms(fs, 2), 2))
    }),
  )
}

///|
test "optimal grid selection remains full rank" {
  let fs = [factor("x", -1.0, 1.0), factor("y", -1.0, 1.0)]
  let result = d_optimal(factorial(fs, [3, 3]), terms(fs, 1), 4)
  assert_true(diagnose(result.plan, terms(fs, 1)).estimable)
  assert_true(result.final_logdet >= result.initial_logdet)
}

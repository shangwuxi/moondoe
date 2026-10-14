///|
test "mixed factorial lexicographic order and budget" {
  let fs = [factor("a", 0.0, 1.0), factor("b", 0.0, 1.0)]
  let p = factorial(fs, [2, 3], centers=1)
  assert_eq(p.runs.length(), 7)
  assert_eq(p.runs[1].point, [-1.0, 0.0])
  assert_eq(p.runs[5].point, [1.0, 1.0])
  assert_true(
    rejected(fn() raise DesignError {
      ignore(factorial(fs, [64, 64], centers=1))
    }),
  )
  assert_eq(two_level(fs).runs.length(), 4)
}

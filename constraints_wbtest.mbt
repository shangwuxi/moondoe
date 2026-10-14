///|
test "candidate constraints preserve provenance and isolation" {
  let fs = [factor("x", -1.0, 1.0), factor("y", -1.0, 1.0)]
  let p = factorial(fs, [3, 3])
  let c = filter_candidates(p, [
    { name: "sum", coefficients: [1.0, 1.0], upper: 0.0, },
  ])
  assert_eq(c.runs.length(), 6)
  for r in c.runs {
    assert_true(r.point[0] + r.point[1] <= 0.0)
  }
  assert_eq(unique_points(replicate(p, 2)).runs.length(), 9)
  let isolated = filter_points(p, fn(row) {
    row[0] = 100.0
    true
  })
  assert_eq(isolated, p)
}

///|
test "half fraction D equals ABC" {
  let fs = [ for n in ["A", "B", "C", "D"] => factor(n, 0.0, 1.0) ]
  let p = fraction(fs, 3, [{ mask: 7, sign: 1, }])
  assert_eq(p.runs.length(), 8)
  for r in p.runs {
    assert_eq(r.point[3], r.point[0] * r.point[1] * r.point[2])
  }
  assert_true(
    rejected(fn() raise DesignError {
      ignore(fraction(fs, 3, [{ mask: 8, sign: 1, }]))
    }),
  )
}

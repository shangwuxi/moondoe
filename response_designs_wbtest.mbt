///|
test "response surface point counts and coordinates" {
  let fs = [ for n in ["a", "b", "c"] => factor(n, -1.0, 1.0) ]
  let c = central_composite(fs, 2.0, centers=3)
  assert_eq(c.runs.length(), 17)
  assert_eq(c.runs[8].point, [-2.0, 0.0, 0.0])
  let b = box_behnken(fs, centers=3)
  assert_eq(b.runs.length(), 15)
  for r in b.runs {
    assert_true(r.point.any(fn(x) { x == 0.0 }))
  }
  assert_true(
    rejected(fn() raise DesignError { ignore(box_behnken([fs[0], fs[1]])) }),
  )
}

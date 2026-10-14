///|
test "foldover and replication" {
  let fs = [ for n in ["A", "B", "C"] => factor(n, -1.0, 1.0) ]
  let p = fraction(fs, 2, [{ mask: 3, sign: 1, }])
  let f = foldover(p, 1)
  assert_eq(f.runs.length(), 8)
  for i in 0..<4 {
    assert_eq(f.runs[i].point[0], -f.runs[i + 4].point[0])
  }
  assert_eq(replicate(p, 3).runs.length(), 12)
  assert_eq(add_centers(p, 2).runs[5].point, [0.0, 0.0, 0.0])
}

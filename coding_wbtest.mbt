///|
test "coding roundtrip and axial extrapolation" {
  let f = factor("heat", 10.0, 30.0)
  assert_eq(decode(f, -1.0), 10.0)
  assert_eq(decode(f, 2.0), 40.0)
  assert_eq(encode(f, 20.0), 0.0)
  let p = physical_plan([f], [[10.0], [40.0]])
  assert_eq(actual_points(p), [[10.0], [40.0]])
  assert_eq(within_bounds(p), ["r2"])
}

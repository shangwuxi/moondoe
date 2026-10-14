///|
test "construction copies caller arrays" {
  let f = [factor("temperature", 20.0, 80.0)]
  let values = [0.0]
  let p = plan(f, [{ id: "a", block: 0, point: values, }])
  values[0] = 8.0
  assert_eq(p.runs[0].point[0], 0.0)
  assert_eq(p.factors[0].name, "temperature")
}

///|
test "invalid factors and runs fail" {
  assert_true((try? factor("x", 1.0, 1.0)) is Err(_))
  assert_true((try? plan([], [])) is Err(_))
  let f = [factor("x", -1.0, 1.0)]
  assert_true((try? plan(f, [{ id: "a", block: 0, point: [], }])) is Err(_))
}

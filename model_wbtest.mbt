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
  assert_true(
    rejected(fn() raise DesignError { ignore(factor("x", 1.0, 1.0)) }),
  )
  assert_true(rejected(fn() raise DesignError { ignore(plan([], [])) }))
  let f = [factor("x", -1.0, 1.0)]
  assert_true(
    rejected(fn() raise DesignError {
      ignore(plan(f, [{ id: "a", block: 0, point: [], }]))
    }),
  )
}

///|
fn rejected(f : () -> Unit raise DesignError) -> Bool {
  try f() catch {
    _ => true
  } noraise {
    _ => false
  }
}

///|
test "JSON plan roundtrip and strict schema" {
  let fs = [factor("temperature", 20.0, 80.0)]
  let p = balanced_blocks(factorial(fs, [3]), 2, 42)
  assert_eq(plan_from_json(plan_json(p)), p)
  assert_true(diagnostics_json(p, terms(fs, 1)).length() > 20)
  assert_true(rejected(fn() raise DesignError { ignore(plan_from_json("{}")) }))
  assert_true(rejected(fn() raise DesignError { ignore(plan_from_json("[]")) }))
  assert_true(
    rejected(fn() raise DesignError {
      ignore(
        plan_from_json("{\"schema\":\"future\",\"factors\":[],\"runs\":[]}"),
      )
    }),
  )
}

///|
test "CSV embedded quotes commas and newlines roundtrip" {
  let fs = [factor("x,\"quoted\"", -1.0, 1.0)]
  let p = plan(fs, [{ id: "a\nb,\"c\"", block: 1, point: [0.25], }])
  assert_eq(plan_from_csv(plan_csv(p), fs), p)
  assert_eq(csv_records("a,b\n"), [["a", "b"]])
  assert_eq(csv_records("a,"), [["a", ""]])
  assert_true(
    rejected(fn() raise DesignError { ignore(csv_records("\"open")) }),
  )
  assert_true(
    rejected(fn() raise DesignError { ignore(csv_records("\"x\"z")) }),
  )
  assert_true(rejected(fn() raise DesignError { ignore(csv_records("a\rb")) }))
}

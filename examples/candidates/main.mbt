///|
fn main raise {
  let fs = [@doe.factor("load", 0.0, 100.0), @doe.factor("voltage", 1.0, 5.0)]
  let grid = @doe.factorial(fs, [5, 5])
  let feasible = @doe.filter_candidates(grid, [
    { name: "load plus voltage", coefficients: [1.0, 1.0], upper: 1.0, },
  ])
  let model = @doe.terms(fs, 1)
  let selected = @doe.d_optimal(feasible, model, 4)
  let extended = @doe.augment_optimal(feasible, model, selected.indices, 6)
  for i in selected.indices {
    assert_true(extended.indices.contains(i))
  }
  let scheduled = @doe.balanced_blocks(extended.plan, 2, 12345)
  for (_, n) in @doe.block_counts(scheduled) {
    assert_eq(n, 3)
  }
  let text = @doe.plan_csv(scheduled)
  assert_eq(@doe.plan_from_csv(text, fs), scheduled)
  assert_eq(@doe.plan_from_json(@doe.plan_json(scheduled)), scheduled)
  println(
    "candidates: feasible bounded D-exchange, protected 4 -> 6 augmentation, two blocks",
  )
  println(text)
}

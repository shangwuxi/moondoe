///|
test "protected augmentation preserves fixed center and input" {
  let fs = [factor("x", -1.0, 1.0)]
  let c = factorial(fs, [5])
  let fixed = [2]
  let r = augment_optimal(c, terms(fs, 1), fixed, 3)
  assert_eq(r.indices[0], 2)
  assert_eq(fixed, [2])
  assert_true(r.indices.contains(0) && r.indices.contains(4))
  let locked = refine_selection(c, terms(fs, 1), [1, 3], locked_prefix=2)
  assert_eq(locked.indices, [1, 3])
  assert_true(
    rejected(fn() raise DesignError {
      ignore(augment_optimal(c, terms(fs, 1), [2, 2], 3))
    }),
  )
}

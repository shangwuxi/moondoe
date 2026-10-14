///|
test "mixed aliases and foldover estimability" {
  let fs = [ for n in ["a", "b", "c"] => factor(n, -1.0, 1.0) ]
  let p = fraction(fs, 2, [{ mask: 3, sign: 1, }])
  let linear = terms(fs, 1)
  assert_true(diagnose(p, linear).estimable)
  let model = linear.copy()
  model.push({ name: "a*b", powers: [1, 1, 0], })
  let d = diagnose(p, model)
  assert_eq(d.rank, 4)
  assert_eq(d.exact_aliases.length(), 1)
  assert_true(diagnose(foldover(p, 1), model).estimable)
  let omitted = design_matrix(p, [{ name: "ab", powers: [1, 1, 0], }])
  let bias = alias_matrix(design_matrix(p, linear), omitted)
  assert_true((bias[3][0] - 1.0).abs() < 1.0e-12)
}

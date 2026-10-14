///|
test "pure error and lack of fit exact hand calculation" {
  let fs = [factor("x", -1.0, 1.0)]
  let p = coded_plan(fs, [[-1.0], [-1.0], [0.0], [0.0], [1.0], [1.0]])
  let e = partition_error(p, terms(fs, 1), [0.0, 2.0, 0.0, 2.0, 4.0, 6.0])
  assert_eq(e.pure_error_sse, 6.0)
  assert_eq(e.pure_error_dof, 3)
  assert_eq(e.lack_of_fit_dof, 1)
  assert_true((e.lack_of_fit_sse - 16.0 / 3.0).abs() < 1.0e-10)
  assert_true(
    (e.residual_sse - e.pure_error_sse - e.lack_of_fit_sse).abs() < 1.0e-10,
  )
  let a = design_matrix(p, terms(fs, 1))
  assert_eq(
    standardized_residuals(
      a,
      fit_plan(p, terms(fs, 1), [0.0, 2.0, 0.0, 2.0, 4.0, 6.0]),
    ).length(),
    6,
  )
}

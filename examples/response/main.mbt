///|
fn main raise {
  let fs = [
    @doe.factor("temperature", 10.0, 50.0),
    @doe.factor("time", 1.0, 9.0),
    @doe.factor("concentration", 0.1, 0.9),
  ]
  let p = @doe.box_behnken(fs, centers=3)
  let model = @doe.terms(fs, 2)
  assert_true(@doe.diagnose(p, model).estimable)
  // Synthetic known surface; centered replicate perturbations demonstrate pure error.
  let responses = [
    for i, r in p.runs => {
      5.0 +
      2.0 * r.point[0] -
      r.point[1] +
      0.5 * r.point[0] * r.point[2] +
      r.point[2] * r.point[2] +
      (if i == 12 { -0.1 } else if i == 14 { 0.1 } else { 0.0 })
    }
  ]
  let fit = @doe.fit_plan(p, model, responses)
  assert_true(
    (@doe.predict(fit.coefficients, model, [0.0, 0.0, 0.0]) - 5.0).abs() <
    1.0e-10,
  )
  let grad = @doe.gradient(fit.coefficients, model, [0.0, 0.0, 0.0])
  assert_true((grad[0] - 2.0).abs() < 1.0e-10)
  let partition = @doe.partition_error(p, model, responses)
  assert_eq(partition.pure_error_dof, 2)
  assert_true((partition.pure_error_sse - 0.02).abs() < 1.0e-10)
  let variance = @doe.variance_profile(p, model, [
    [0.0, 0.0, 0.0],
    [0.5, 0.0, 0.0],
  ])
  assert_true(variance[0] > 0.0)
  let ccd = @doe.central_composite(fs, 1.5, centers=2)
  assert_eq(@doe.within_bounds(ccd).length(), 6)
  println(
    "response: 15-run BBD, 10-term quadratic, pure-error SS=0.02; CCD axial bounds reported",
  )
}

///|
fn main raise {
  let fs = [
    @doe.factor("temperature", 20.0, 80.0),
    @doe.factor("pressure", 1.0, 5.0),
    @doe.factor("speed", 100.0, 300.0),
  ]
  let generators : Array[@doe.Generator] = [{ mask: 3, sign: 1, }]
  let half = @doe.fraction(fs, 2, generators)
  assert_eq(@doe.resolution(2, generators), Some(3))
  let interaction : @doe.Term = {
    name: "temperature*pressure",
    powers: [1, 1, 0],
  }
  let model = @doe.terms(fs, 1)
  model.push(interaction)
  assert_eq(@doe.diagnose(half, model).rank, 4)
  let full = @doe.foldover(half, 4)
  assert_true(@doe.diagnose(full, model).estimable)
  let response = [
    for r in full.runs => {
      10.0 +
      2.0 * r.point[0] -
      r.point[1] +
      3.0 * r.point[2] +
      0.5 * r.point[0] * r.point[1]
    }
  ]
  let fit = @doe.fit_plan(full, model, response)
  assert_true((fit.coefficients[4] - 0.5).abs() < 1.0e-10)
  let actual = @doe.actual_points(full)
  assert_eq(actual.length(), 8)
  println("screening: resolution III, 4 -> 8 runs, interaction identifiable")
  println(@doe.diagnostics_json(full, model))
}

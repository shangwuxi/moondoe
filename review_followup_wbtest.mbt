///|
test "FOLLOWUP R11 diagnostic JSON obeys the advertised text budget" {
  let fs = [ for j in 0..<7 => factor("f\{j}", -1.0, 1.0) ]
  let p = coded_plan(fs, [Array::make(7, 1.0)])
  let model : Array[Term] = [
    for i in 0..<128 => {
      {
        name: "n".repeat(252) + i.to_string(),
        powers: [
          for j in 0..<7 => (i >> j) & 1
        ],
      }
    }
  ]
  let text = diagnostics_json(p, model) catch {
    DesignError::Budget(_) => return
    e => raise e
  }
  assert_true(text.length() <= 2000000)
}

///|
test "FOLLOWUP R12 centered physical values preserve an identifiable design" {
  let fs = [factor("x", -1.0, 1.0)]
  let p = physical_plan(fs, [[-1.0e-20], [1.0e-20]])
  assert_eq(p.runs[0].point[0], -1.0e-20)
  assert_eq(p.runs[1].point[0], 1.0e-20)
  let fit = fit_plan(p, terms(fs, 1), [-2.0, 2.0])
  assert_true((fit.coefficients[1] / 2.0e20 - 1.0).abs() < 1.0e-12)
}

///|
test "FOLLOWUP R12 centered decoding keeps small signed coordinates" {
  let f = factor("x", -1.0, 1.0)
  assert_eq(decode(f, -1.0e-20), -1.0e-20)
  assert_eq(decode(f, 1.0e-20), 1.0e-20)
}

///|
test "FOLLOWUP R11 normal diagnostics retain the public JSON schema" {
  let fs = [factor("x", -1.0, 1.0)]
  let p = two_level(fs)
  let text = diagnostics_json(p, terms(fs, 1))
  assert_true(text.length() < 2000000)
  let value = @json.parse(text)
  match value {
    Object(fields) => {
      assert_eq(fields.length(), 9)
      assert_eq(fields.get("estimable"), Some(Json(true)))
      assert_eq(fields.get("runs"), Some(Json(2)))
    }
    _ => fail("diagnostics must be a JSON object")
  }
}

///|
test "FOLLOWUP R12 midpoint rounding correction on narrow positive intervals" {
  let f = factor("narrow", 1.0, 1.0000000000000007)
  assert_true((encode(f, 1.0000000000000002) + 1.0 / 3.0).abs() < 1.0e-15)
  assert_true((encode(f, 1.0000000000000004) - 1.0 / 3.0).abs() < 1.0e-15)
}

///|
test "FOLLOWUP R12 subnormal widths preserve interior values and extrapolation" {
  let unit = 5.0e-324
  let f = factor("tiny", unit, 4.0 * unit)
  assert_true((encode(f, 2.0 * unit) + 1.0 / 3.0).abs() < 1.0e-15)
  assert_true((encode(f, 3.0 * unit) - 1.0 / 3.0).abs() < 1.0e-15)
  assert_eq(decode(f, -1.0), f.low)
  assert_eq(decode(f, 1.0), f.high)
  assert_eq(encode(f, f.low), -1.0)
  assert_eq(encode(f, f.high), 1.0)
  let normal = factor("normal", -3.0, 1.0)
  assert_eq(decode(normal, -2.0), -5.0)
  assert_eq(decode(normal, 2.0), 3.0)
  assert_eq(encode(normal, -5.0), -2.0)
  assert_eq(encode(normal, 3.0), 2.0)
}

///|
test "FOLLOWUP R12 independent rational centered coordinate oracle" {
  let cases : Array[(Double, Double, Double)] = [
    (1.0e-300, -1.0e-20, -1.0e-320),
    (1.0e-300, 1.0e-20, 1.0e-320),
    (1.0e-300, -0.5, -5.0e-301),
    (1.0e-300, 0.5, 5.0e-301),
    (1.0e-200, -1.0e-20, -1.0e-220),
    (1.0e-200, 1.0e-20, 1.0e-220),
    (1.0e-200, -0.5, -5.0e-201),
    (1.0e-200, 0.5, 5.0e-201),
    (1.0e-100, -1.0e-20, -1.0e-120),
    (1.0e-100, 1.0e-20, 1.0e-120),
    (1.0e-100, -0.5, -5.0e-101),
    (1.0e-100, 0.5, 5.0e-101),
    (1.0e-20, -1.0e-20, -1.0e-40),
    (1.0e-20, 1.0e-20, 1.0e-40),
    (1.0e-20, -0.5, -5.0e-21),
    (1.0e-20, 0.5, 5.0e-21),
    (1.0, -1.0e-20, -1.0e-20),
    (1.0, 1.0e-20, 1.0e-20),
    (1.0, -0.5, -0.5),
    (1.0, 0.5, 0.5),
    (1.0e+20, -1.0e-20, -1.0),
    (1.0e+20, 1.0e-20, 1.0),
    (1.0e+20, -0.5, -5.0e+19),
    (1.0e+20, 0.5, 5.0e+19),
    (1.0e+80, -1.0e-20, -1.0e+60),
    (1.0e+80, 1.0e-20, 1.0e+60),
    (1.0e+80, -0.5, -5.0e+79),
    (1.0e+80, 0.5, 5.0e+79),
    (1.0e+100, -1.0e-20, -1.0e+80),
    (1.0e+100, 1.0e-20, 1.0e+80),
    (1.0e+100, -0.5, -5.0e+99),
    (1.0e+100, 0.5, 5.0e+99),
  ]
  for (scale, coded, physical) in cases {
    let f = factor("symmetric", -scale, scale)
    let decoded = decode(f, coded)
    let encoded = encode(f, physical)
    assert_true(decoded != 0.0)
    // Subnormal physical outputs have quantization error; exact double input
    // division still supplies the independent expected code in those cases.
    assert_true((decoded / physical - 1.0).abs() < 1.0e-12)
    let expected_code = physical / scale
    assert_true((encoded / expected_code - 1.0).abs() < 1.0e-12)
  }
}

///|
test "FOLLOWUP R11 large permitted Unicode diagnostic reports remain usable" {
  let fs = [ for j in 0..<7 => factor("f\{j}", -1.0, 1.0) ]
  let p = coded_plan(fs, [Array::make(7, 1.0)])
  let model : Array[Term] = [
    for i in 0..<128 => {
      {
        name: "😀".repeat(20) + i.to_string(),
        powers: [
          for j in 0..<7 => (i >> j) & 1
        ],
      }
    }
  ]
  let text = diagnostics_json(p, model)
  assert_true(text.length() <= 2000000)
  match @json.parse(text) {
    Object(fields) =>
      match fields.get("exact_aliases") {
        Some(Array(aliases)) => assert_eq(aliases.length(), 8128)
        _ => fail("alias array required")
      }
    _ => fail("diagnostic object required")
  }
}

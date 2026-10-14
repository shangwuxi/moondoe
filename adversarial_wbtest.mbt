///|
test "signed defining groups agree with every generated run" {
  for base in 1..<5 {
    for mask in 1..<(1 << base) {
      for sign in [-1, 1] {
        let fs = [ for j in 0..<(base + 1) => factor("x\{j}", -1.0, 1.0) ]
        let gs : Array[Generator] = [{ mask, sign, }]
        let p = fraction(fs, base, gs)
        let relation = defining_relation(base, gs)
        assert_eq(relation.length(), 2)
        for w in relation {
          for r in p.runs {
            let mut product = 1.0
            for j in 0..<fs.length() {
              if (w.mask & (1 << j)) != 0 {
                product *= r.point[j]
              }
            }
            assert_eq(product, w.sign.to_double())
          }
        }
        for effect in 0..<(1 << fs.length()) {
          for aliased in aliases(effect, base, gs) {
            for r in p.runs {
              let mut left = 1.0
              let mut right = aliased.sign.to_double()
              for j in 0..<fs.length() {
                if (effect & (1 << j)) != 0 {
                  left *= r.point[j]
                }
                if (aliased.mask & (1 << j)) != 0 {
                  right *= r.point[j]
                }
              }
              assert_eq(left, right)
            }
          }
        }
      }
    }
  }
}

///|
test "small grid D selection matches an independent determinant enumeration" {
  let fs = [factor("x", -1.0, 1.0), factor("y", -1.0, 1.0)]
  let p = factorial(fs, [3, 3])
  let mut best = 0.0
  for a in 0..<6 {
    for b in (a + 1)..<7 {
      for c in (b + 1)..<8 {
        for d in (c + 1)..<9 {
          let ids = [a, b, c, d]
          let mut sx = 0.0
          let mut sy = 0.0
          let mut xx = 0.0
          let mut xy = 0.0
          let mut yy = 0.0
          for i in ids {
            let x = p.runs[i].point[0]
            let y = p.runs[i].point[1]
            sx += x
            sy += y
            xx += x * x
            xy += x * y
            yy += y * y
          }
          let det = 4.0 * (xx * yy - xy * xy) -
            sx * (sx * yy - xy * sy) +
            sy * (sx * xy - xx * sy)
          if det > best {
            best = det
          }
        }
      }
    }
  }
  assert_eq(best, 64.0)
  let result = d_optimal(p, terms(fs, 1), 4)
  assert_true((result.final_logdet - @math.ln(best)).abs() < 1.0e-10)
}

///|
test "weighted QR satisfies analytical weighted normal equations" {
  let a = [[1.0, 0.0], [1.0, 1.0], [1.0, 2.0], [1.0, 3.0]]
  let y = [1.0, 2.0, 2.0, 4.0]
  let w = [1.0, 2.0, 3.0, 4.0]
  let f = least_squares(a, y, weights=w)
  // X'WX = [[10,20],[20,50]], X'Wy=[27,64].
  assert_true((f.coefficients[0] - 0.7).abs() < 1.0e-12)
  assert_true((f.coefficients[1] - 1.0).abs() < 1.0e-12)
  for j in 0..<2 {
    let mut sum = 0.0
    for i in 0..<4 {
      sum += w[i] * a[i][j] * f.residuals[i]
    }
    assert_true(sum.abs() < 1.0e-11)
  }
}

///|
test "QR scale and pivot permutation preserve coefficient units" {
  let a = [
    [1.0, -2.0e-12, 4.0e12],
    [1.0, -1.0e-12, 1.0e12],
    [1.0, 0.0, 0.0],
    [1.0, 1.0e-12, 1.0e12],
    [1.0, 2.0e-12, 4.0e12],
  ]
  let y = [11.0, 4.0, 3.0, 8.0, 19.0]
  let f = least_squares(a, y)
  assert_true((f.coefficients[0] - 3.0).abs() < 1.0e-10)
  assert_true((f.coefficients[1] / 2.0e12 - 1.0).abs() < 1.0e-10)
  assert_true((f.coefficients[2] / 3.0e-12 - 1.0).abs() < 1.0e-10)
  assert_eq(matrix_rank(a), 3)
}

///|
test "singular and nearly dependent systems fail deliberately" {
  assert_true(
    rejected(fn() raise DesignError {
      ignore(least_squares([[1.0, 1.0], [2.0, 2.0]], [1.0, 2.0]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(least_squares([[1.0, 1.0], [1.0, 1.0 + 1.0e-12]], [1.0, 2.0]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(inverse([[1.0, 2.0], [2.0, 4.0]]))
    }),
  )
  assert_eq(log_determinant([[1.0, 2.0], [2.0, 1.0]]), None)
}

///|
test "matrix malformed inputs reject without aborts" {
  assert_true(
    rejected(fn() raise DesignError { ignore(matrix_rank([[1.0], [1.0, 2.0]])) }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(multiply([[1.0]], [[1.0, 2.0], [3.0, 4.0]]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(information([[1.0]], weights=[0.0]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(log_determinant([[1.0, 0.1], [0.0, 1.0]]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError { ignore(matrix_rank([[1.0]], tol=0.0)) }),
  )
}

///|
test "huge counts and masks reject before integer overflow" {
  let fs = [factor("x", -1.0, 1.0)]
  assert_true(
    rejected(fn() raise DesignError {
      ignore(central_composite(fs, 1.0, centers=2147483647))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(defining_relation(2147483647, [{ mask: 1, sign: 1, }]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError { ignore(factorial(fs, [2147483647])) }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(replicate(two_level(fs), 2147483647))
    }),
  )
}

///|
test "public mutable data is revalidated and copies stay isolated" {
  let fs = [factor("x", -1.0, 1.0)]
  let p = two_level(fs)
  let q = randomize(p, 7)
  q.runs[0].point[0] = 0.3
  assert_true(p.runs[0].point[0] == -1.0)
  p.runs[0].point[0] = 1.0e101
  assert_true(rejected(fn() raise DesignError { ignore(plan_json(p)) }))
  assert_true(
    rejected(fn() raise DesignError { ignore(diagnose(p, terms(fs, 1))) }),
  )
}

///|
test "nonfinite numeric values and invalid terms reject" {
  assert_true(
    rejected(fn() raise DesignError { ignore(factor("x", 0.0, 1.0 / 0.0)) }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(evaluate_terms([0.0 / 0.0], [{ name: "I", powers: [0], }]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(evaluate_terms([1.0], [{ name: "x", powers: [9], }]))
    }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(
        evaluate_terms([1.0], [
          { name: "x", powers: [1], },
          { name: "copy", powers: [1], },
        ]),
      )
    }),
  )
}

///|
test "strict interchange rejects malformed and schema mismatched data" {
  let fs = [factor("x", -1.0, 1.0)]
  for
    text in [
      "", "{", "[]", "{\"schema\":\"other\"}", "[[[[[[[[[0]]]]]]]]]", "{\"a\":NaN}",
    ] {
    assert_true(
      rejected(fn() raise DesignError { ignore(plan_from_json(text)) }),
    )
  }
  for
    text in [
      "id,block,x\nr1,0", "id,block,x\nr1,-1,0", "id,block,x\nr1,0,NaN", "id,block,x\nr1,0,0\nr1,0,1",
      "id,block,x\nr1,0,\"unterminated", "wrong,block,x\nr1,0,0",
    ] {
    assert_true(
      rejected(fn() raise DesignError { ignore(plan_from_csv(text, fs)) }),
    )
  }
}

///|
test "CSV and JSON retain unicode quotes newlines and backslashes" {
  let fs = [factor("温度,\"\\\n", 10.0, 30.0)]
  let p = plan(fs, [{ id: "试验,\"\\\n", block: 2, point: [0.25], }])
  assert_eq(plan_from_csv(plan_csv(p), fs), p)
  assert_eq(plan_from_json(plan_json(p)), p)
}

///|
test "protected selection rejects duplicate out of range and singular sets" {
  let fs = [factor("x", -1.0, 1.0)]
  let p = factorial(fs, [3])
  let m = terms(fs, 1)
  assert_true(
    rejected(fn() raise DesignError { ignore(augment_optimal(p, m, [0, 0], 2)) }),
  )
  assert_true(
    rejected(fn() raise DesignError { ignore(augment_optimal(p, m, [3], 2)) }),
  )
  assert_true(
    rejected(fn() raise DesignError { ignore(refine_selection(p, m, [0, 0])) }),
  )
  assert_true(
    rejected(fn() raise DesignError {
      ignore(refine_selection(p, m, [0, 1], locked_prefix=3))
    }),
  )
}

///|
test "replicate grouping respects blocks and SS decomposition" {
  let fs = [factor("x", -1.0, 1.0)]
  let p = plan(fs, [
    { id: "a", block: 1, point: [-1.0], },
    { id: "b", block: 2, point: [-1.0], },
    { id: "c", block: 1, point: [1.0], },
    { id: "d", block: 2, point: [1.0], },
  ])
  let y = [0.0, 2.0, 2.0, 4.0]
  let m = terms(fs, 1)
  let split = partition_error(p, m, y)
  let pooled = partition_error(p, m, y, separate_blocks=false)
  assert_eq(split.pure_error_dof, 0)
  assert_eq(pooled.pure_error_dof, 2)
  assert_true((pooled.pure_error_sse - 4.0).abs() < 1.0e-12)
  assert_true(
    (pooled.residual_sse - pooled.pure_error_sse - pooled.lack_of_fit_sse).abs() <
    1.0e-12,
  )
}

///|
test "randomization is a reproducible permutation for a range of seeds" {
  let fs = [factor("x", -1.0, 1.0), factor("y", -1.0, 1.0)]
  let p = factorial(fs, [3, 3])
  for seed in 1..<=50 {
    let q = randomize(p, seed)
    assert_eq(q, randomize(p, seed))
    assert_eq(q.runs.length(), p.runs.length())
    for r in p.runs {
      assert_true(q.runs.contains(r))
    }
    let blocked = balanced_blocks(p, 3, seed)
    for (_, count) in block_counts(blocked) {
      assert_eq(count, 3)
    }
  }
  assert_true(rejected(fn() raise DesignError { ignore(randomize(p, 0)) }))
}

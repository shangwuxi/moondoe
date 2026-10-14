///|
test "reproducible random permutation and balanced blocks" {
  let p = factorial([factor("x", -1.0, 1.0)], [10])
  assert_eq(randomize(p, 7), randomize(p, 7))
  let q = balanced_blocks(p, 3, 7)
  assert_eq(block_counts(q), [(1, 4), (2, 3), (3, 3)])
  let r = randomize(q, 9, within_blocks=true)
  assert_eq(block_counts(r), [(1, 4), (2, 3), (3, 3)])
  for row in r.runs {
    assert_true(
      q.runs.any(fn(s) {
        s.id == row.id && s.block == row.block && s.point == row.point
      }),
    )
  }
  assert_true(rejected(fn() raise DesignError { ignore(randomize(p, 0)) }))
}

///|
test "Park Miller official integer recurrence" {
  let r = rng(1)
  assert_eq(draw(r, 2147483646), 16806)
  assert_eq(r.state, 16807L)
}

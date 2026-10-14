///|
test "resolution IV and signed alias oracle" {
  let g : Array[Generator] = [{ mask: 7, sign: -1, }]
  assert_eq(resolution(3, g), Some(4))
  assert_eq(defining_relation(3, g), [
    { mask: 0, sign: 1, },
    { mask: 15, sign: -1, },
  ])
  assert_eq(aliases(1, 3, g)[1], { mask: 14, sign: -1, })
  assert_eq(effect_name(14, ["A", "B", "C", "D"]), "B*C*D")
  assert_eq(resolution(2, []), None)
}

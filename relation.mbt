///|
pub(all) struct DefiningWord {
  mask : Int
  sign : Int
} derive(Debug, Eq)

///|
pub extend DefiningWord with @debug.Debug::{to_repr}

///|
pub extend DefiningWord with Eq::{equal, not_equal}

///|
fn parity(x : Int) -> Int {
  let mut n = x
  let mut count = 0
  while n > 0 {
    count += n & 1
    n = n >> 1
  }
  count
}

///|
pub fn defining_relation(
  base : Int,
  generators : Array[Generator],
) -> Array[DefiningWord] raise DesignError {
  if base < 1 ||
    base > 16 ||
    generators.length() > 10 ||
    base > 16 - generators.length() {
    raise Budget("defining relation exceeds factor/word budget")
  }
  let words : Array[DefiningWord] = [{ mask: 0, sign: 1, }]
  for i, g in generators {
    if g.mask <= 0 || g.mask >= 1 << base || (g.sign != 1 && g.sign != -1) {
      raise Invalid("invalid generator")
    }
    let word = g.mask | (1 << (base + i))
    let size = words.length()
    for j in 0..<size {
      words.push({ mask: words[j].mask ^ word, sign: words[j].sign * g.sign, })
    }
  }
  words
}

///|
pub fn resolution(
  base : Int,
  generators : Array[Generator],
) -> Int? raise DesignError {
  let mut result : Int? = None
  for word in defining_relation(base, generators) {
    if word.mask != 0 {
      let length = parity(word.mask)
      result = match result {
        None => Some(length)
        Some(n) => Some(if length < n { length } else { n })
      }
    }
  }
  result
}

///|
pub fn aliases(
  effect : Int,
  base : Int,
  generators : Array[Generator],
) -> Array[DefiningWord] raise DesignError {
  let words = defining_relation(base, generators)
  if effect < 0 || effect >= 1 << (base + generators.length()) {
    raise Invalid("effect mask out of range")
  }
  [
    for word in words => { mask: word.mask ^ effect, sign: word.sign, }
  ]
}

///|
pub fn effect_name(
  mask : Int,
  names : Array[String],
) -> String raise DesignError {
  if names.length() > 16 || mask < 0 || mask >= 1 << names.length() {
    raise Invalid("effect mask out of range")
  }
  if mask == 0 {
    return "I"
  }
  let selected = []
  for j, name in names {
    if (mask & (1 << j)) != 0 {
      selected.push(name)
    }
  }
  selected.join("*")
}

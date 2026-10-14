///|
priv struct DesignRng {
  mut state : Int64
}

///|
fn rng(seed : Int) -> DesignRng raise DesignError {
  if seed < 1 || seed > 2147483646 {
    raise Invalid("seed must be 1..2147483646")
  }
  { state: seed.to_int64(), }
}

///|
fn draw(random : DesignRng, bound : Int) -> Int {
  let limit = 2147483646L / bound.to_int64() * bound.to_int64()
  let mut value = limit
  while value >= limit {
    random.state = random.state * 16807L % 2147483647L
    value = random.state - 1L
  }
  (value % bound.to_int64()).to_int()
}

///|
fn shuffled(runs : Array[Run], random : DesignRng) -> Array[Run] {
  let result = runs.copy()
  for i = result.length() - 1; i > 0; i = i - 1 {
    let j = draw(random, i + 1)
    let tmp = result[i]
    result[i] = result[j]
    result[j] = tmp
  }
  result
}

///|
pub fn randomize(
  p : Plan,
  seed : Int,
  within_blocks? : Bool = false,
) -> Plan raise DesignError {
  validate_plan(p)
  let random = rng(seed)
  if !within_blocks {
    return plan(p.factors, shuffled(p.runs, random))
  }
  let blocks : Array[Int] = []
  for r in p.runs {
    if !blocks.contains(r.block) {
      blocks.push(r.block)
    }
  }
  if blocks.length() > 64 {
    raise Budget("within-block randomization supports <=64 blocks")
  }
  let runs = []
  for block in blocks {
    let group = p.runs.filter(fn(r) { r.block == block })
    for r in shuffled(group, random) {
      runs.push(r)
    }
  }
  plan(p.factors, runs)
}

///|
pub fn balanced_blocks(
  p : Plan,
  count : Int,
  seed : Int,
) -> Plan raise DesignError {
  validate_plan(p)
  if count < 1 || count > 64 || count > p.runs.length() {
    raise Budget("block count must be 1..min(64,runs)")
  }
  let mixed = randomize(p, seed)
  let runs = [ for i, r in mixed.runs => { ..r, block: i % count + 1, } ]
  plan(p.factors, runs)
}

///|
pub fn block_counts(p : Plan) -> Array[(Int, Int)] raise DesignError {
  validate_plan(p)
  let ids : Array[Int] = []
  let counts : Array[Int] = []
  for r in p.runs {
    let mut index = -1
    for i, id in ids {
      if id == r.block {
        index = i
        break
      }
    }
    if index < 0 {
      ids.push(r.block)
      counts.push(1)
    } else {
      counts[index] += 1
    }
  }
  [
    for i, id in ids => (id, counts[i])
  ]
}

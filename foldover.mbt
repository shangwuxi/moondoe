///|
pub fn foldover(
  p : Plan,
  mask : Int32,
  include_original~ : Bool = true,
) -> Plan raise DesignError {
  validate_plan(p)
  if mask <= 0 || mask >= 1 << p.factors.length() {
    raise Invalid("foldover mask must select known factors")
  }
  if include_original && p.runs.length() > 2048 {
    raise Budget("foldover exceeds 4096 runs")
  }
  let runs : Array[Run] = if include_original { p.runs.copy() } else { [] }
  for r in p.runs {
    let point = r.point.copy()
    for j in 0..<point.length() {
      if (mask & (1 << j)) != 0 {
        point[j] = -point[j]
      }
    }
    runs.push({ id: "fold:\{r.id}", block: r.block, point, })
  }
  plan(p.factors, runs)
}

///|
pub fn replicate(p : Plan, copies : Int32) -> Plan raise DesignError {
  validate_plan(p)
  if copies < 1 || copies > 4096 / p.runs.length() {
    raise Budget("replication exceeds run budget")
  }
  let runs : Array[Run] = []
  for k in 0..<copies {
    for r in p.runs {
      runs.push({ ..r, id: "rep\{k+1}:\{r.id}", })
    }
  }
  plan(p.factors, runs)
}

///|
pub fn add_centers(
  p : Plan,
  count : Int32,
  block~ : Int32 = 0,
) -> Plan raise DesignError {
  validate_plan(p)
  if count < 0 || count > 4096 - p.runs.length() {
    raise Budget("center augmentation exceeds run budget")
  }
  let runs = p.runs.copy()
  for k in 0..<count {
    runs.push({
      id: "center\{k+1}",
      block,
      point: Array::make(p.factors.length(), 0.0),
    })
  }
  plan(p.factors, runs)
}

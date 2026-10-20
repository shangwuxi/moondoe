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
  let used = [ for r in runs => r.id ]
  for r in p.runs {
    let point = r.point.copy()
    for j in 0..<point.length() {
      if (mask & (1 << j)) != 0 {
        point[j] = -point[j]
      }
    }
    let id = fresh_name("fold:\{r.id}", used, 128, "fold:")
    used.push(id)
    runs.push({ id, block: r.block, point, })
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
  let used : Array[String] = []
  for k in 0..<copies {
    for r in p.runs {
      let id = fresh_name("rep\{k+1}:\{r.id}", used, 128, "rep:")
      used.push(id)
      runs.push({ ..r, id, })
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
  let used = [ for r in runs => r.id ]
  for k in 0..<count {
    let id = fresh_name("center\{k+1}", used, 128, "center")
    used.push(id)
    runs.push({ id, block, point: Array::make(p.factors.length(), 0.0), })
  }
  plan(p.factors, runs)
}

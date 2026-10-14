///|
fn object_fields(
  value : Json,
  keys : Array[String],
) -> Map[String, Json] raise DesignError {
  let obj = match value {
    Object(x) => x
    _ => raise Invalid("JSON object required")
  }
  if obj.length() != keys.length() {
    raise Invalid("JSON object schema mismatch")
  }
  for key in keys {
    if obj.get(key) is None {
      raise Invalid("JSON required field missing")
    }
  }
  obj
}

///|
fn json_field(obj : Map[String, Json], name : String) -> Json raise DesignError {
  match obj.get(name) {
    Some(x) => x
    None => raise Invalid("missing JSON field")
  }
}

///|
fn json_string(value : Json) -> String raise DesignError {
  match value {
    String(x) => x
    _ => raise Invalid("JSON string required")
  }
}

///|
fn json_number(value : Json) -> Double raise DesignError {
  let x = match value {
    Number(n, ..) => n
    _ => raise Invalid("JSON number required")
  }
  require_number(x)
  x
}

///|
fn json_array(value : Json, limit : Int) -> Array[Json] raise DesignError {
  let a = match value {
    Array(x) => x
    _ => raise Invalid("JSON array required")
  }
  if a.length() > limit {
    raise Budget("JSON array exceeds schema budget")
  }
  a
}

///|
pub fn plan_json(p : Plan) -> String raise DesignError {
  validate_plan(p)
  let fs : Array[Json] = [
    for f in p.factors => {
      Json::object({
        "name": f.name.to_json(),
        "low": f.low.to_json(),
        "high": f.high.to_json(),
      })
    }
  ]
  let rs : Array[Json] = [
    for r in p.runs => {
      Json::object({
        "id": r.id.to_json(),
        "block": r.block.to_json(),
        "point": r.point.to_json(),
      })
    }
  ]
  Json::object({
    "schema": "moondoe/1".to_json(),
    "factors": Json::array(fs),
    "runs": Json::array(rs),
  }).stringify()
}

///|
pub fn plan_from_json(text : String) -> Plan raise DesignError {
  if text.length() > 2000000 {
    raise Budget("JSON exceeds two million UTF-16 units")
  }
  check_json_depth(text)
  let value = @json.parse(text) catch {
    _ => raise Invalid("invalid or deeply nested JSON")
  }
  let root = object_fields(value, ["schema", "factors", "runs"])
  if json_string(json_field(root, "schema")) != "moondoe/1" {
    raise Invalid("unsupported plan schema")
  }
  let fs = []
  for row in json_array(json_field(root, "factors"), 16) {
    let obj = object_fields(row, ["name", "low", "high"])
    fs.push(
      factor(
        json_string(json_field(obj, "name")),
        json_number(json_field(obj, "low")),
        json_number(json_field(obj, "high")),
      ),
    )
  }
  let rs = []
  for row in json_array(json_field(root, "runs"), 4096) {
    let obj = object_fields(row, ["id", "block", "point"])
    let block = json_number(json_field(obj, "block"))
    if block < 0.0 ||
      block > 2147483647.0 ||
      block != block.to_int().to_double() {
      raise Invalid("block must be nonnegative Int")
    }
    let point = [
      for x in json_array(json_field(obj, "point"), 16) => json_number(x)
    ]
    rs.push({
      id: json_string(json_field(obj, "id")),
      block: block.to_int(),
      point,
    })
  }
  plan(fs, rs)
}

///|
pub fn diagnostics_json(
  p : Plan,
  model : Array[Term],
) -> String raise DesignError {
  let d = diagnose(p, model)
  let aliases : Array[Json] = [
    for pair in d.exact_aliases => {
      Json::object({
        "left": pair.left.to_json(),
        "right": pair.right.to_json(),
        "correlation": pair.correlation.to_json(),
      })
    }
  ]
  Json::object({
    "runs": d.runs.to_json(),
    "terms": d.terms.to_json(),
    "rank": d.rank.to_json(),
    "estimable": d.estimable.to_json(),
    "residual_dof": d.residual_dof.to_json(),
    "zero_columns": d.zero_columns.to_json(),
    "exact_aliases": Json::array(aliases),
    "max_abs_correlation": d.max_abs_correlation.to_json(),
    "log_determinant": d.log_determinant.to_json(),
  }).stringify()
}

///|
// Preflight bounds nesting without depending on deprecated core parser options.
fn check_json_depth(text : String) -> Unit raise DesignError {
  let mut depth = 0
  let mut quoted = false
  let mut escaped = false
  for ch in text {
    if quoted {
      if escaped {
        escaped = false
      } else if ch == '\\' {
        escaped = true
      } else if ch == '"' {
        quoted = false
      }
    } else if ch == '"' {
      quoted = true
    } else if ch == '{' || ch == '[' {
      depth += 1
      if depth > 8 {
        raise Budget("JSON nesting exceeds eight")
      }
    } else if ch == '}' || ch == ']' {
      depth -= 1
    }
  }
}

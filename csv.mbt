///|
fn csv_field(value : String) -> String {
  let out = StringBuilder()
  out.write_char('"')
  for c in value.to_array() {
    if c == '"' {
      out.write_char('"')
    }
    out.write_char(c)
  }
  out.write_char('"')
  out.to_string()
}

///|
pub fn plan_csv(p : Plan) -> String raise DesignError {
  validate_plan(p)
  let lines = []
  let header = ["id", "block"]
  for f in p.factors {
    header.push(f.name)
  }
  lines.push(header.map(csv_field).join(","))
  for r in p.runs {
    let fields = [csv_field(r.id), r.block.to_string()]
    for value in r.point {
      fields.push(value.to_string())
    }
    lines.push(fields.join(","))
  }
  let text = lines.join("\r\n") + "\r\n"
  if text.length() > 2000000 {
    raise Budget("CSV exceeds two million UTF-16 units")
  }
  text
}

///|
pub fn csv_records(text : String) -> Array[Array[String]] raise DesignError {
  if text.length() > 2000000 {
    raise Budget("CSV exceeds two million UTF-16 units")
  }
  let chars = text.to_array()
  let rows = []
  let fields : Array[String] = []
  let mut field = StringBuilder()
  let mut state = 0
  let mut pending = false
  let mut i = 0
  while i < chars.length() {
    let c = chars[i]
    if state == 1 {
      if c == '"' {
        if i + 1 < chars.length() && chars[i + 1] == '"' {
          field.write_char('"')
          i += 1
        } else {
          state = 2
        }
      } else {
        field.write_char(c)
      }
      pending = true
    } else if c == ',' || c == '\n' || c == '\r' {
      let value = field.to_string()
      if value.length() > 4096 || fields.length() >= 18 {
        raise Budget("CSV field/column limit exceeded")
      }
      fields.push(value)
      field = StringBuilder()
      state = 0
      pending = true
      if c != ',' {
        if c == '\r' {
          if i + 1 >= chars.length() || chars[i + 1] != '\n' {
            raise Invalid("bare CR outside quoted CSV field")
          }
          i += 1
        }
        if rows.length() >= 4097 {
          raise Budget("CSV row limit exceeded")
        }
        rows.push(fields.copy())
        fields.clear()
        pending = false
      }
    } else {
      if state == 2 {
        raise Invalid("characters after closing CSV quote")
      }
      if c == '"' {
        if field.to_string().length() != 0 {
          raise Invalid("quote in unquoted CSV field")
        }
        state = 1
      } else {
        field.write_char(c)
      }
      pending = true
    }
    i += 1
  }
  if state == 1 {
    raise Invalid("unterminated CSV quote")
  }
  if pending {
    let value = field.to_string()
    if value.length() > 4096 || fields.length() >= 18 || rows.length() >= 4097 {
      raise Budget("CSV limit exceeded")
    }
    fields.push(value)
    rows.push(fields.copy())
  }
  rows
}

///|
fn parse_number(text : String) -> Double raise DesignError {
  if text.length() > 128 {
    raise Budget("numeric text exceeds 128 units")
  }
  let json = @json.parse(text) catch {
    _ => raise Invalid("invalid JSON-format numeric field")
  }
  let value = match json {
    Number(x, ..) => x
    _ => raise Invalid("numeric field required")
  }
  require_number(value)
  value
}

///|
pub fn plan_from_csv(
  text : String,
  factors : Array[Factor],
) -> Plan raise DesignError {
  validate_factors(factors)
  let rows = csv_records(text)
  if rows.length() < 2 {
    raise Invalid("CSV header and runs required")
  }
  let header = ["id", "block"]
  for f in factors {
    header.push(f.name)
  }
  if rows[0] != header {
    raise Invalid("CSV header must match exact factor names")
  }
  let runs = []
  for i in 1..<rows.length() {
    let row = rows[i]
    if row.length() != header.length() {
      raise Invalid("CSV row width mismatch")
    }
    let number = parse_number(row[1])
    if number < 0.0 ||
      number > 2147483647.0 ||
      number != number.to_int().to_double() {
      raise Invalid("block must be a nonnegative Int")
    }
    let point = [ for j in 2..<row.length() => parse_number(row[j]) ]
    runs.push({ id: row[0], block: number.to_int(), point, })
  }
  plan(factors, runs)
}

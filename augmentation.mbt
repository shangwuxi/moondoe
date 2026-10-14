///|
pub fn augment_optimal(
  candidates : Plan,
  model : Array[Term],
  fixed_indices : Array[Int],
  total_runs : Int,
  passes? : Int = 4,
) -> OptimalResult raise DesignError {
  optimal_budget(candidates, model, total_runs, passes)
  if fixed_indices.length() > total_runs {
    raise Budget("fixed runs exceed final run budget")
  }
  for j, i in fixed_indices {
    if i < 0 || i >= candidates.runs.length() {
      raise Invalid("fixed candidate index out of range")
    }
    for k in 0..<j {
      if fixed_indices[k] == i {
        raise Invalid("duplicate fixed candidate index")
      }
    }
  }
  let rows = design_matrix(candidates, model)
  let selected = seed_selection(rows, total_runs, fixed_indices)
  improve_selection(candidates, model, selected, fixed_indices.length(), passes)
}

///|
pub fn refine_selection(
  candidates : Plan,
  model : Array[Term],
  initial : Array[Int],
  locked_prefix? : Int = 0,
  passes? : Int = 4,
) -> OptimalResult raise DesignError {
  optimal_budget(candidates, model, initial.length(), passes)
  if locked_prefix < 0 || locked_prefix > initial.length() {
    raise Invalid("invalid locked prefix")
  }
  for j, i in initial {
    if i < 0 || i >= candidates.runs.length() {
      raise Invalid("selection index out of range")
    }
    for k in 0..<j {
      if initial[k] == i {
        raise Invalid("duplicate selection index")
      }
    }
  }
  improve_selection(candidates, model, initial, locked_prefix, passes)
}

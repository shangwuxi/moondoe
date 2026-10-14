///|
pub(all) struct OptimalResult {
  plan : Plan
  indices : Array[Int]
  initial_logdet : Double
  final_logdet : Double
  improvements : Array[Double]
  exchanges : Int
  converged : Bool
} derive(Debug, Eq)

///|
pub extend OptimalResult with @debug.Debug::{to_repr}

///|
pub extend OptimalResult with Eq::{equal, not_equal}

///|
fn selection_matrix(
  rows : Array[Array[Double]],
  indices : Array[Int],
) -> Array[Array[Double]] {
  [
    for i in indices => rows[i].copy()
  ]
}

///|
fn selection_score(
  rows : Array[Array[Double]],
  indices : Array[Int],
) -> Double? raise DesignError {
  log_determinant(information(selection_matrix(rows, indices)))
}

///|
fn seed_selection(
  rows : Array[Array[Double]],
  count : Int,
  fixed : Array[Int],
) -> Array[Int] raise DesignError {
  let selected = fixed.copy()
  let mut rank = if selected.length() == 0 {
    0
  } else {
    matrix_rank(selection_matrix(rows, selected))
  }
  let p = rows[0].length()
  for i in 0..<rows.length() {
    if rank == p {
      break
    }
    if selected.contains(i) {
      continue
    }
    let trial = selected.copy()
    trial.push(i)
    let next = matrix_rank(selection_matrix(rows, trial))
    if next > rank {
      selected.push(i)
      rank = next
    }
  }
  if rank < p || selected.length() > count {
    raise Singular(
      "candidate/fixed set cannot seed a full rank design within budget",
    )
  }
  while selected.length() < count {
    let mut chosen = -1
    let mut best : Double? = None
    for i in 0..<rows.length() {
      if selected.contains(i) {
        continue
      }
      let trial = selected.copy()
      trial.push(i)
      match selection_score(rows, trial) {
        Some(score) =>
          if (match best {
              None => true
              Some(b) => score > b + 1.0e-12
            }) {
            best = Some(score)
            chosen = i
          }
        None => ()
      }
    }
    if chosen < 0 {
      raise Singular("could not augment full rank seed")
    }
    selected.push(chosen)
  }
  selected
}

///|
fn improve_selection(
  candidates : Plan,
  model : Array[Term],
  indices : Array[Int],
  locked : Int,
  passes : Int,
) -> OptimalResult raise DesignError {
  let rows = design_matrix(candidates, model)
  let selected = indices.copy()
  let initial = match selection_score(rows, selected) {
    Some(x) => x
    None => raise Singular("initial selection not SPD")
  }
  let mut score = initial
  let improvements = [initial]
  let mut exchanges = 0
  let mut converged = false
  for _ in 0..<passes {
    let mut changed = false
    for slot in locked..<selected.length() {
      let old = selected[slot]
      let mut chosen = old
      let mut best = score
      for candidate in 0..<rows.length() {
        if selected.contains(candidate) {
          continue
        }
        selected[slot] = candidate
        match selection_score(rows, selected) {
          Some(value) =>
            if value > best + 1.0e-10 {
              chosen = candidate
              best = value
            }
          None => ()
        }
        selected[slot] = old
      }
      selected[slot] = chosen
      if chosen != old {
        score = best
        exchanges += 1
        changed = true
        improvements.push(score)
      }
    }
    if !changed {
      converged = true
      break
    }
  }
  let p = plan(candidates.factors, [ for i in selected => candidates.runs[i] ])
  {
    plan: p,
    indices: selected,
    initial_logdet: initial,
    final_logdet: score,
    improvements,
    exchanges,
    converged,
  }
}

///|
fn optimal_budget(
  candidates : Plan,
  model : Array[Term],
  count : Int,
  passes : Int,
) -> Unit raise DesignError {
  validate_plan(candidates)
  validate_terms(model, candidates.factors.length())
  if candidates.runs.length() > 256 ||
    model.length() > 16 ||
    count < model.length() ||
    count > 64 ||
    count > candidates.runs.length() ||
    passes < 1 ||
    passes > 16 {
    raise Budget(
      "optimal design requires <=256 candidates, <=16 terms, terms<=runs<=64, and 1..16 passes",
    )
  }
  let work = count.to_int64() *
    candidates.runs.length().to_int64() *
    (passes + count).to_int64() *
    model.length().to_int64() *
    model.length().to_int64() *
    model.length().to_int64()
  if work > 100000000L {
    raise Budget(
      "optimal design estimated factorization work exceeds 100 million",
    )
  }
}

///|
pub fn d_optimal(
  candidates : Plan,
  model : Array[Term],
  count : Int,
  passes? : Int = 4,
) -> OptimalResult raise DesignError {
  optimal_budget(candidates, model, count, passes)
  let rows = design_matrix(candidates, model)
  let selected = seed_selection(rows, count, [])
  improve_selection(candidates, model, selected, 0, passes)
}

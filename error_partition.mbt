///|
pub(all) struct ErrorPartition {
  residual_sse : Double
  pure_error_sse : Double
  lack_of_fit_sse : Double
  pure_error_dof : Int32
  lack_of_fit_dof : Int32
  f_ratio : Double?
  groups : Int32
} derive(Debug, Eq)

///|
pub extend ErrorPartition with @debug.Debug::{to_repr}

///|
pub extend ErrorPartition with Eq::{equal, not_equal}

///|
pub fn partition_error(
  p : Plan,
  model : Array[Term],
  responses : Array[Double],
  separate_blocks~ : Bool = true,
) -> ErrorPartition raise DesignError {
  validate_plan(p)
  let fit = fit_plan(p, model, responses)
  let representatives : Array[Int32] = []
  let members : Array[Array[Int32]] = []
  for i, r in p.runs {
    let mut group = -1
    for j, index in representatives {
      let other = p.runs[index]
      if r.point == other.point && (!separate_blocks || r.block == other.block) {
        group = j
        break
      }
    }
    if group < 0 {
      representatives.push(i)
      members.push([i])
    } else {
      members[group].push(i)
    }
  }
  let mut pure = 0.0
  for group in members {
    let reference = responses[group[0]]
    let mut offset = 0.0
    for i in group {
      offset += (responses[i] - reference) / group.length().to_double()
    }
    let mean = reference + offset
    require_number(mean)
    for i in group {
      let delta = responses[i] - mean
      pure += delta * delta
    }
  }
  require_number(pure)
  let mut lack = fit.sse - pure
  if lack < 0.0 {
    if -lack > 1.0e-8 * (1.0 + fit.sse + pure) {
      raise Invalid("residual partition lost numerical consistency")
    }
    lack = 0.0
  }
  let pure_dof = p.runs.length() - members.length()
  let lack_dof = members.length() - model.length()
  let ratio = if pure_dof > 0 && lack_dof > 0 && pure > 0.0 {
    Some(lack / lack_dof.to_double() / (pure / pure_dof.to_double()))
  } else {
    None
  }
  {
    residual_sse: fit.sse,
    pure_error_sse: pure,
    lack_of_fit_sse: lack,
    pure_error_dof: pure_dof,
    lack_of_fit_dof: lack_dof,
    f_ratio: ratio,
    groups: members.length(),
  }
}

///|
pub fn standardized_residuals(
  a : Array[Array[Double]],
  fit : Fit,
) -> Array[Double?] raise DesignError {
  let (n, p) = matrix_shape(a)
  if fit.residuals.length() != n ||
    fit.coefficients.length() != p ||
    fit.dof != n - p {
    raise Invalid("fit does not match matrix shape")
  }
  let h = leverage(a)
  let variance = match fit.variance {
    None => return Array::make(n, None)
    Some(v) => v
  }
  require_number(variance)
  if variance < 0.0 {
    raise Invalid("negative fit variance")
  }
  let result = []
  for i, e in fit.residuals {
    require_number(e)
    let denom = variance * (1.0 - h[i])
    result.push(if denom > 1.0e-14 { Some(e / denom.sqrt()) } else { None })
  }
  result
}

# Numerical contracts and limitations

All accepted scalars must satisfy `x == x && abs(x) <= 1e100`. This is intentionally stricter
than IEEE finiteness. Intermediate/results are range checked where they leave numerical routines.
Finite input alone cannot prevent all rounding, underflow, ill-conditioning or cancellation.

## Physical and coded coordinates

Exact physical endpoints map to -1/+1 and back. Encoding forms the centered
numerator `2*actual-low-high` with a compensated sum, including the midpoint's
rounding correction for narrow intervals. Decoding uses the midpoint near coded
zero, anchors at the closer endpoint away from the center, and avoids halving a
subnormal span. This preserves small signed centered perturbations that an
endpoint-first subtraction or `coded+1` would erase. It does not promise correctly
rounded results for every interval/extrapolation or recover information already
lost when callers construct their Double inputs.

## Rank, fits and information

- Rank: columns divided by their max absolute magnitude; partial-pivot elimination;
  pivots <= `tol` are absent. Threshold is relative to initially equilibrated columns.
- Least squares: positive weights, square-root weighting, max-column equilibration,
  pivoted two-pass modified Gram–Schmidt, then back substitution and unit restoration.
  Squared remaining-column norm <= `tol²` is rank deficient. This is not Householder QR/SVD;
  difficult ill-conditioned problems require an independent mature solver.
- Inverse: square matrix, initial row max equilibration, partial pivoting, pivot <= `tol`
  rejects. No pseudoinverse, sparse solver or condition-number estimate.
- SPD logdet: pairwise relative symmetry check without an absolute unit floor, diagonal equilibration, Cholesky positive-pivot test.
  Every pair is checked before nonpositive-diagonal classification; tolerance is relative to the sum of both off-diagonal magnitudes.
  Nonpositive diagonal/pivot yields None; asymmetric shape/content throws Invalid.
  None is an identifiability warning, not a valid determinant of an indefinite matrix.
- Weighted information: X'WX with strictly positive weights. `covariance` is
  `variance*(X'WX)^(-1)`, not robust/sandwich covariance. Forming X'X squares conditioning.
  Leverage and variance profiles use this route, even when a fit used QR.

Rank estimators and Cholesky can disagree near tolerance; no assertion forces them to agree.
Diagnostics use **uncentered column cosine**, not Pearson correlation. `exact_aliases` means
absolute cosine within tolerance of 1; it is an approximate signed collinearity diagnostic.
Polynomial term order is intercept, main effects, pair interactions, then squares.

## Residuals and prediction

`least_squares` SSE is weighted residual SSE; stored residuals/fitted values remain in original
response units. `dof=n-p`; estimated variance is SSE/dof, None for saturated designs.
Standardized residuals require positive variance and dimensionless `1-h > 1e-14`; they divide by separate square roots to avoid a tiny denominator product. Zero variance or effectively unit leverage yields None.
`fit_plan`, `leverage`, `partition_error` and `standardized_residuals` are unweighted.
Do not pass a weighted Fit to standardized_residuals expecting weighted leverage correction.

Prediction variance is row'Cov(row), a mean-response variance, not future-observation variance.
A negative quadratic is rejected unless its magnitude is at most `1e-10` of the sum of absolute quadratic contributions; only that relative cancellation error is clamped to zero. This is a query-specific check, not a full PSD certification of caller-supplied covariance.
`variance_profile` uses unit residual variance; caller scales it for an estimated variance.
Gradient is with respect to **coded** coordinates. Physical-coordinate gradients require the
linear coding chain rule. The polynomial alone does not enforce factor bounds.

Pure-error groups require exact coordinate equality and by default equal block IDs. Replicate
means use reference-relative summation; SS partitions clamp only small negative rounding error.
No replicates/saturated fits/zero pure error can yield absent F ratio. Ratios are descriptive;
no p-value, distribution calibration, hypothesis rejection or uncertainty interval is implemented.
The F ratio is range-checked like other scalar results; a positive but very small pure-error SS cannot cause an unchecked Infinity result.

## Budgets and optimality

D exchange evaluates finite candidates with recomputed information/Cholesky; improvements
must exceed absolute `1e-10` in logdet. It accepts a local rank seed and can reject numerically
singular feasible sets. Protected rows are immutable; rank completion may need more slots than
available even if a different seed would work. No global optimum promise is made.

The work guard `runs*candidates*(passes+runs)*terms³ <= 100000000` is a conservative declared
factorization estimate, not CPU instructions/time. Validation/alias analysis add work.
All general design routines bound allocation, but 4096 runs can still incur quadratic validation.
Web/server callers should also enforce time/memory and input-size limits outside this library.

Small analytical tests validate equations and boundaries. They cannot establish accuracy for
all data scales, pathological nearly dependent designs or safety-critical scientific conclusions.

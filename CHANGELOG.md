# Changelog

## 0.1.2 — 2026-10-20

- Preserve tiny signed centered physical/coded coordinates instead of collapsing distinct design points.
- Compensate the rounded midpoint when encoding narrow intervals; retain exact endpoints and subnormal-width handling.
- Extend the two-million UTF-16 output budget to diagnostic JSON without changing its schema.
- Add 8 regression tests including public physical-plan fitting, exact-rational coordinate values, Unicode reports and isolated boundary cases.
- Keep all previous tests, public signatures, runtime dependencies and supported targets unchanged.

## 0.1.1 — 2026-10-20

- Allocate collision-free bounded execution IDs and polynomial labels; keep ordinary names unchanged.
- Preserve endpoint mappings and subnormal interval widths in physical/coded conversions.
- Enforce the same two-million UTF-16-unit budget for CSV/JSON output and input.
- Apply the 1..16 dimension budget consistently at the gradient entry point.
- Use scale-relative symmetry checks before SPD classification, including nonpositive diagonals.
- Preserve standardized residuals across response units using dimensionless leverage guards.
- Range-check lack-of-fit F ratios and avoid premature subnormal denominator underflow.
- Scale negative prediction-variance tolerance by the absolute quadratic contributions.
- Add 18 regression tests, including maximum-run, supplementary-Unicode IDs and numerical scale families.
- Pin versioned official CI toolchain URLs and SHA-256 instead of relying on moving latest objects.
- Preserve public API signatures; invalid inputs and out-of-budget results are now rejected consistently.

## 0.1.0 — 2026-10-14

- Validated coded/physical plans with bounded resources and isolated ownership.
- Full/fractional factorial, signed defining relations and aliases, selective foldover,
  replication, centers, central-composite and Box–Behnken plans.
- Explicit polynomial terms, equilibrated rank, weighted information and pivoted
  two-pass MGS QR; estimability, omitted-term projection, covariance and gradient.
- Deterministic finite-candidate D exchange, locked augmentation and refinement.
- Feasibility filters, unbiased seeded run permutations, balanced blocks and error partition.
- Bounded CSV and schema-versioned JSON interchange; three executable workflows.
- Analytical/exhaustive/adversarial tests and reproducible four-target verification.

Initial release; no backwards-compatibility promise beyond the documented 0.1.0 interface.

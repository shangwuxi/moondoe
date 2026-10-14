# Provenance and reference boundary

MoonDOE is an original implementation, not a source translation or port. MIT applies to
project source/tests/docs. Only MoonBit's standard library is imported (core/debug,
core/math, core/json and builtins), maintained at https://github.com/moonbitlang/core
under Apache-2.0; it is resolved by the toolchain and is not vendored here.

Signed regular defining groups, central-composite/Box–Behnken designs, modified
Gram–Schmidt QR, Cholesky information scoring and Fedorov-style single-row exchanges
are mathematical techniques, not claims of original algorithm invention. All implementation
and fixtures here are self-authored; no external tables or sample data were redistributed.

Conceptual comparison targets (not linked runtime dependencies or automated differential oracles):
- R AlgDesign: https://cran.r-project.org/package=AlgDesign — candidate-set optimal design;
  MoonDOE implements bounded single-row D exchange, not its full criteria/search suite.
- pyDOE3: https://github.com/relf/pyDOE3 — DOE generators;
  MoonDOE includes regular signed fractions, CCD and BBD, not its complete catalog.
- Adjacent MoonBit modules: zhaoyuanjuns/moonbit_extractor@0.1.2,
  weidekais/moonbit-adsorption@0.2.1, pla678889/moon-experiment@0.2.3,
  jdjjttr/montecarlo@0.1.0. Their source was read for capability boundaries;
  none of their code is included or a runtime dependency.

The 3×3 linear-model determinant oracle is independently expanded as a polynomial;
weighted coefficients are checked against the explicitly written 2×2 normal equations.
No R/Python reference run, external benchmark, proof or complete equivalence is claimed.

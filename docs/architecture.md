# Architecture and ownership

`Factor` is a continuous physical interval. `Run` carries stable provenance ID, nonnegative
block ID and coded point. `Plan` groups a factor schema and ordered runs. Constructors
validate uniqueness, shape and numeric bounds and copy mutable arrays. Operations preserve
factor order; ID prefixes identify replicated/folded runs. Conflicting/generated IDs or IDs
longer than 128 are errors, not silently renamed. Repeated `add_centers` can conflict with
existing center IDs; users can construct explicitly named runs when merging many stages.

Data pipeline:
1. Checked constructors and coordinate transforms (`model`, `coding`).
2. Design generation/defining algebra (`factorial`, `fraction`, `relation`, `foldover`, `response_designs`).
3. Explicit model monomials → design matrix → diagnostics/QR/information (`terms`, `matrix`, `inverse`, `fit`, `diagnostics`).
4. Predictions/error decomposition (`prediction`, `error_partition`).
5. Constraint-filtered finite candidates → rank seed → protected exchanges (`constraints`, `optimal`, `augmentation`).
6. Reproducible ordered execution → bounded interchange (`randomization`, `csv`, `json_plan`).

Generators use low bits for independent factors; each dependent factor is `sign * product(mask)`.
Defining words use one additional bit per dependent factor. The defining group is expanded
by XOR masks and multiplication of signs. Alias classes multiply an effect by every word.
Resolution is the shortest non-identity defining word, or None for no defining generators.

D exchange operates without replacement on candidate **indices**, not unique coordinates.
Use `unique_points` if distinct coordinates are required. `augment_optimal` fixes the supplied
indices as an immutable prefix; `refine_selection` can lock a prefix of an existing ordered
selection. Filtered candidate sets have new indexing; save the same candidate plan with indices.
The result reports initial/final logdet, strictly improving history, exchanges and termination.
It is not coordinate descent over an unbounded continuous domain.

Randomization uses Park–Miller Int64 state and rejection-sampled Fisher–Yates draws.
It is reproducible, noncryptographic, seed range 1..2147483646. Within-block randomization
returns contiguous blocks in first-seen block order; it does not preserve interleaved slots.
Balanced blocks assign shuffled runs cyclically; this balances counts, not model orthogonality.
Block IDs affect grouping/scheduling, not fitted nuisance parameters. Include explicit custom
model columns outside this monomial API if a separate block-effect analysis is required.

The library uses no filesystem/network/process/global credentials. Examples print to stdout;
the caller chooses storage and physical execution. Source/API/code-limit inventory is generated
read-only by `scripts/audit.py`. CI and consumer validation are separate gates from unit tests.

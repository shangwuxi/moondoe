# Engineering audit before remote writes

2026-10-14, Asia/Shanghai. Original independent MoonDOE repository; unrelated parent repository is not included.
Account/namespace: shangwuxi / shangwuxi/moondoe. Public identity binding is stored only in .git metadata.
No credential, private application or contact data belongs in this repository or package.

## Local acceptance at this revision

- Toolchain: moon 0.1.20261012, moonc v0.10.15+943464bfa; official pinned objects in install script.
- `moon info && moon fmt`, reviewed generated signatures; `moon fmt --check` passes.
- wasm-gc/wasm/js: strict check, all38 tests, build and all3 assertive workflows pass.
- native: strict MoonBit check passes; local C compiler absent, no local native execution claim.
- Production inventory: 20 root non-test .mbt, 2219 physical lines, no vendor/copied/generated/example inclusion.
- 52 signed one-generator designs and all their rows/effect aliases checked; 126 four-row selections
  from a 3×3 grid compared with an independently expanded 3×3 determinant; weighted analytical
  coefficients, 49 random seeds, malformed interchanges and integer-overflow bounds tested.
- 25 implementation/documentation/CI commits exist before this audit; conservative valid count24.
  Exclude migration/format/interface maintenance; this audit-only commit and later release-only
  microfixes do not increase the conservative engineering total.
- Real public CI/publication/consumer validation are separate gates, not claimed by local tests.

## Commit provenance and purpose

Validation column records the actual local engineering-session checks, not CI results.
Final target-matrix regression covers retained features; no invented historical upstream tests.
Each subject describes an independently retained slice. All author/committer emails use selected
account's verified numeric noreply identity. Raw count can be reproduced by scripts/audit.py.

| Full SHA | Purpose | Changed paths | Validation | Conservative valid |
|---|---|---|---|---|
| `e2b4a388fb00dd66c056c64ce7362bf6a14d109d` | feat: validate bounded factor and run models with ownership isolation | `.gitignore`, `model.mbt`, `model_test.mbt`, `moon.mod`, `moon.pkg` | moon fmt + moon test --deny-warn at feature completion | yes |
| `38c40318450485f836e23b3cdeb7905cb88ba62d` | feat: provide checked physical-to-coded coordinate transforms | `coding.mbt`, `coding_wbtest.mbt`, `model.mbt`, `model_test.mbt`, `model_wbtest.mbt`, `moon.pkg` | moon fmt + moon test --deny-warn at feature completion | yes |
| `87b2356a8b252391741e34daf32282de8cbb5b1d` | feat: enumerate bounded mixed-level factorial experiments | `factorial.mbt`, `factorial_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `1a10e405dd840c46567a8ba233acde7bb6a87805` | feat: construct regular binary fractions from signed generators | `fraction.mbt`, `fraction_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `6c18b0fbcbfe5f2d9e2980769c28b7ed3ff966a7` | feat: derive signed defining words resolution and effect aliases | `relation.mbt`, `relation_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `51374e30a185652c717781dba111d591656a240b` | feat: fold selected factors and preserve auditable replicate identities | `foldover.mbt`, `foldover_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `8e3beb07c31f8defb0f9b6c8246f84d54bf29e47` | feat: generate central composite and Box-Behnken response surface plans | `response_designs.mbt`, `response_designs_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `603ca2538a578d194110725add6deefd6e9de7d0` | feat: build checked polynomial models and explicit design matrices | `terms.mbt`, `terms_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `05234982fd24b6153a19454f663069ca6f830080` | feat: add equilibrated matrix rank and weighted information algebra | `matrix.mbt`, `matrix_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `4ff61758d501b540f5b8bbc75ab05ced34f64bd2` | feat: invert scaled information matrices and score SPD log determinants | `inverse.mbt`, `inverse_wbtest.mbt`, `model.mbt`, `moon.pkg` | moon fmt + moon test --deny-warn at feature completion | yes |
| `178747623bca2c7a7f8653035885279805403928` | feat: solve weighted models with pivoted reorthogonalized QR | `fit.mbt`, `fit_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `2ee6a19e5f419f12b2984963671ca6f7d4de0fdc` | feat: diagnose estimability signed column aliases and omitted-term bias | `diagnostics.mbt`, `diagnostics_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `83b2d8f6dab95b5be69675a6097744c4e67a7066` | feat: assess prediction variance leverage covariance and model gradients | `prediction.mbt`, `prediction_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `8799464ee8df67bcf531d0742723e6a7078208ee` | feat: select finite candidate designs with bounded monotone D optimal exchange | `optimal.mbt`, `optimal_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `15d836ddcda017ea2aee46e0a05380dbf975e86a` | feat: augment existing designs while protecting performed candidate runs | `augmentation.mbt`, `augmentation_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `e600b5758fa20720e66918be20a67b6866f6beab` | feat: filter feasible candidates with provenance and isolated predicates | `constraints.mbt`, `constraints_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `28fb19e9fa7c148a54ac77e6a010b09e17de2c7c` | feat: randomize reproducibly with unbiased bounded draws and balanced blocks | `randomization.mbt`, `randomization_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `e27c6cf388d9dcf409db1c17bee618de3ec97814` | feat: partition replication error and lack of fit with residual diagnostics | `error_partition.mbt`, `error_partition_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `ca2d8227f1bb268c3cc0f19bdb7deb12b5b194f6` | feat: exchange bounded quoted CSV run plans with strict schema validation | `csv.mbt`, `csv_wbtest.mbt`, `moon.pkg` | moon fmt + moon test --deny-warn at feature completion | yes |
| `014f35f2c4c2f06fe2094245919168fbe129c5eb` | feat: strict bounded JSON plan interchange and diagnostic reports | `json_plan.mbt`, `json_plan_wbtest.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `3548fb43ecdbfb6e33789df408ea76870ba12917` | test: independently enumerate aliases and determinants; guard extreme count overflow | `adversarial_wbtest.mbt`, `relation.mbt`, `response_designs.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `dc4955eb60a87177b3563ee613bb999daf642921` | feat: three downstream workflows for screening response surfaces and constrained budgets | `examples/candidates/main.mbt`, `examples/candidates/moon.pkg`, `examples/response/main.mbt`, `examples/response/moon.pkg`, `examples/screening/main.mbt`, `examples/screening/moon.pkg`, `json_plan.mbt` | moon fmt + moon test --deny-warn at feature completion | yes |
| `28bfeb5d7f0ff79553fbd0b9c705327de0fdb69d` | fix: support October toolchain JSON conversion and record public interfaces | `augmentation.mbt`, `constraints.mbt`, `diagnostics.mbt`, `error_partition.mbt`, `examples/candidates/pkg.generated.mbti`, `examples/response/pkg.generated.mbti`, `examples/screening/pkg.generated.mbti`, `factorial.mbt`, `fit.mbt`, `foldover.mbt`, `fraction.mbt`, `inverse.mbt`, `json_plan.mbt`, `matrix.mbt`, `model.mbt`, `optimal.mbt`, `pkg.generated.mbti`, `prediction.mbt`, `randomization.mbt`, `relation.mbt`, `response_designs.mbt`, `terms.mbt` | October 12 toolchain: info/fmt/check/test strict; conservative count excluded | no |
| `17a993cfa87d992caa23a105509f3484a148b067` | docs: document reusable workflows numerical contracts licensing and semantic selection | `.gitattributes`, `AI-USE.md`, `ATTRIBUTION.md`, `CHANGELOG.md`, `LICENSE`, `README.md`, `SECURITY.md`, `docs/architecture.md`, `docs/competition/duplicate-check.md`, `docs/numerics.md` | documentation reviewed against implementation and measured results | yes |
| `7b05ffba10a2e6e1b7edd82a0efb5e08065cc83a` | ci: reproduce strict four-target checks interfaces and example assertions | `.github/workflows/ci.yml`, `scripts/audit.py`, `scripts/install-ci-toolchain.sh`, `scripts/verify.sh` | local strict checks/tests/build/examples (3 executable targets); native check; actual CI not yet run | yes |

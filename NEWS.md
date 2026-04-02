# inrep 0.3.2 (2026-04-02)

## Dependency cleanup

- Dropped `uuid` and `digest` from Imports; replaced with base R
  implementations (`generate_uuid()` now uses random hex sampling,
  session hashing uses `as.hexmode()`).

- Moved `DT` and `rmarkdown` from Imports to Suggests. Both were already
  guarded with `requireNamespace()` checks; no functional change.

- Removed `%||%` export — base R >= 4.1.0 provides `base::%||%`.
  Eliminates masking conflict with `purrr::%||%` and `base::%||%`.

- Removed `get_label()` export — only used internally for multilingual
  label lookup. Eliminates masking conflict with `sjlabelled::get_label`.

- Removed `%r%` export — unused string-repetition operator.

- Net effect: Imports reduced from 10 packages to 5 (`shiny`, `later`,
  `stats`, `utils`, `graphics`, `jsonlite`). Cleaner `library(inrep)` with
  no masking messages.

# inrep 0.3.1 (2026-04-02)

## Bug fixes

- `fast_select_next_item()` previously used the 2PL formula for all models
  including GRM; now delegates to `compute_item_info_single()`.

- Removed duplicate `%||%` definition in `study_management.R` (already
  exported from `core_utils.R`).

- Regenerated Rd files to resolve codoc mismatch on `save_session_to_cloud`.

- Replaced em dashes (non-ASCII) in `platform_deployment.R` with `--`.

- Added `rsconnect` to `Suggests` to resolve undeclared import warning.

- Fixed sign error in Samejima GRM boundary probability formula across three
  independent locations (`parallel_utils.R`, `item_selection.R`,
  `core_utils.R`). The old formula used `exp(a*(theta - b))` instead of
  `exp(-a*(theta - b))`, producing negative middle-category probabilities and
  effectively zeroing out GRM item information in adaptive selection.

- Replaced incorrect GRM information approximation `a^2 * sum(P*(1-P))` with
  the correct Samejima formula `sum(dP^2 / P)` using boundary-curve
  derivatives.

## Breaking / deprecation

- `enable_llm_assistance()` and `generate_llm_prompt()` are deprecated. Both
  emit a message pointing to inrep-studio. Functions remain exported for
  backward compatibility.

- `get_llm_assistance_settings()` deprecated; no replacement.

## Architecture notes

- GRM (Samejima) and TAM's GPCM (step-deviation parameterization) are distinct
  models and their parameters do not map 1:1. GRM support is flagged
  experimental in `create_study_config()` and documented throughout. 1PL, 2PL,
  and 3PL TAM integration verified correct.

- Consolidated `compute_item_info()` local copy in `item_selection.R` to
  delegate to the canonical `compute_item_info_single()` in
  `parallel_utils.R`, eliminating the duplicate.

## Documentation

- Trimmed bloated `@examples` sections in `bfi_items.R`, `math_items.R`,
  `cognitive_items_data.R`, and `estimate_ability.R`. Removed inaccurate
  return-value descriptions.

- `copilot-instructions.md` rewritten: removed outdated LLM-first framing,
  added accurate model/TAM section, documented GRM/GPCM distinction, corrected
  false claim that `IRT.informationCurves()` is used in item selection.

- `inrep-package.R` and README updated to reflect inrep-studio as the primary
  configuration entry point.

## Removed

- `R/study_configurator.R` and `R/study_configurator_utils.R` (empty files,
  no references).

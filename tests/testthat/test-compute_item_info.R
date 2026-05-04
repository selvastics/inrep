# Tests for compute_item_info_single() — canonical IRT item information function
# Reference formulas:
#   1PL/2PL: I(θ) = a² · P(θ) · (1 − P(θ))   where P = 1/(1+exp(−a(θ−b)))
#   3PL:     I(θ) = a² · (P − c)² · Q / (P · (1−c)²)
#   At θ = b (2PL): I(b) = a²/4  (maximum information for 2PL)
#   GRM:     I(θ) = Σ [dPk/dθ]² / Pk  (Samejima, 1969)

library(testthat)
library(inrep)

# ── helpers ──────────────────────────────────────────────────────────────────

make_bank <- function(...) data.frame(..., stringsAsFactors = FALSE)
cfg <- function(model) list(model = model)

# ── 1PL ──────────────────────────────────────────────────────────────────────

test_that("1PL: information at theta = b equals 0.25 (a=1)", {
  bank <- make_bank(a = 1, b = 0)
  info <- compute_item_info_single(theta = 0, item_idx = 1, item_bank = bank, config = cfg("1PL"))
  expect_equal(info, 0.25, tolerance = 1e-10)
})

test_that("1PL: information is non-negative across theta range", {
  bank <- make_bank(a = 1, b = 0)
  thetas <- seq(-4, 4, by = 0.5)
  infos <- vapply(thetas, function(th)
    compute_item_info_single(th, 1, bank, cfg("1PL")), numeric(1))
  expect_true(all(infos >= 0))
})

test_that("1PL: information decreases away from item difficulty", {
  bank <- make_bank(a = 1, b = 0)
  i_at_b    <- compute_item_info_single(0,  1, bank, cfg("1PL"))
  i_off_1   <- compute_item_info_single(1,  1, bank, cfg("1PL"))
  i_off_neg <- compute_item_info_single(-1, 1, bank, cfg("1PL"))
  expect_gt(i_at_b, i_off_1)
  expect_gt(i_at_b, i_off_neg)
})

# ── 2PL ──────────────────────────────────────────────────────────────────────

test_that("2PL: maximum information at theta = b equals a^2/4", {
  bank <- make_bank(a = 1.5, b = 0.5)
  info <- compute_item_info_single(0.5, 1, bank, cfg("2PL"))
  expect_equal(info, 1.5^2 / 4, tolerance = 1e-10)
})

test_that("2PL: higher discrimination yields higher peak information", {
  bank_low  <- make_bank(a = 0.5, b = 0)
  bank_high <- make_bank(a = 2.0, b = 0)
  i_low  <- compute_item_info_single(0, 1, bank_low,  cfg("2PL"))
  i_high <- compute_item_info_single(0, 1, bank_high, cfg("2PL"))
  expect_gt(i_high, i_low)
})

test_that("2PL: information is symmetric around b", {
  bank <- make_bank(a = 1.2, b = 1.0)
  i_above <- compute_item_info_single(2.0, 1, bank, cfg("2PL"))
  i_below <- compute_item_info_single(0.0, 1, bank, cfg("2PL"))
  expect_equal(i_above, i_below, tolerance = 1e-10)
})

# ── 3PL ──────────────────────────────────────────────────────────────────────

test_that("3PL: c=0 reduces to 2PL formula", {
  bank2 <- make_bank(a = 1.2, b = 0.3)
  bank3 <- make_bank(a = 1.2, b = 0.3, c = 0)
  i2 <- compute_item_info_single(0.3, 1, bank2, cfg("2PL"))
  i3 <- compute_item_info_single(0.3, 1, bank3, cfg("3PL"))
  expect_equal(i2, i3, tolerance = 1e-10)
})

test_that("3PL: guessing (c>0) reduces information relative to c=0", {
  bank_c0  <- make_bank(a = 1.0, b = 0, c = 0.0)
  bank_c25 <- make_bank(a = 1.0, b = 0, c = 0.25)
  i_c0  <- compute_item_info_single(0, 1, bank_c0,  cfg("3PL"))
  i_c25 <- compute_item_info_single(0, 1, bank_c25, cfg("3PL"))
  expect_gt(i_c0, i_c25)
})

test_that("3PL: information is non-negative", {
  bank <- make_bank(a = 1.0, b = 0, c = 0.2)
  thetas <- seq(-4, 4, by = 1)
  infos <- vapply(thetas, function(th)
    compute_item_info_single(th, 1, bank, cfg("3PL")), numeric(1))
  expect_true(all(infos >= 0))
})

# ── GRM ──────────────────────────────────────────────────────────────────────

test_that("GRM: information is non-negative for 3-category item", {
  bank <- make_bank(a = 1.5, b1 = -1, b2 = 1)
  thetas <- seq(-3, 3, by = 0.5)
  infos <- vapply(thetas, function(th)
    compute_item_info_single(th, 1, bank, cfg("GRM")), numeric(1))
  expect_true(all(infos >= 0))
})

test_that("GRM: peak information is in the range covered by thresholds", {
  bank <- make_bank(a = 1.5, b1 = -1, b2 = 1)
  thetas <- seq(-3, 3, by = 0.25)
  infos <- vapply(thetas, function(th)
    compute_item_info_single(th, 1, bank, cfg("GRM")), numeric(1))
  peak_theta <- thetas[which.max(infos)]
  expect_true(peak_theta >= -1.5 && peak_theta <= 1.5)
})

test_that("GRM: higher discrimination yields higher peak information", {
  bank_lo <- make_bank(a = 0.5, b1 = -1, b2 = 1)
  bank_hi <- make_bank(a = 2.0, b1 = -1, b2 = 1)
  i_lo <- compute_item_info_single(0, 1, bank_lo, cfg("GRM"))
  i_hi <- compute_item_info_single(0, 1, bank_hi, cfg("GRM"))
  expect_gt(i_hi, i_lo)
})

# ── Edge cases ────────────────────────────────────────────────────────────────

test_that("NA discrimination is handled without error", {
  bank <- make_bank(a = NA, b = 0)
  expect_no_error(compute_item_info_single(0, 1, bank, cfg("2PL")))
})

test_that("NA difficulty is handled without error", {
  bank <- make_bank(a = 1, b = NA)
  expect_no_error(compute_item_info_single(0, 1, bank, cfg("2PL")))
})

test_that("Extreme theta values return finite non-negative result", {
  bank <- make_bank(a = 1, b = 0)
  i_high <- compute_item_info_single(100, 1, bank, cfg("2PL"))
  i_low  <- compute_item_info_single(-100, 1, bank, cfg("2PL"))
  expect_true(is.finite(i_high) && i_high >= 0)
  expect_true(is.finite(i_low)  && i_low  >= 0)
})

# Tests TC-11 und TC-12 aus Kapitel 8 der Anforderungsanalyse (K7) und
# Fehlerfälle des Trendtests in R/statistik.R

test_that("TC-11: Reihe 1 bis 10 ergibt S = 45, Var = 125, Z = 3,94, Sen = 1", {
  skip_if_not_installed("trend")
  ergebnis <- trendtest(1:10, parameter)
  expect_equal(ergebnis$n, 10)
  expect_equal(ergebnis$s, 45)
  expect_equal(ergebnis$var_s, 125)
  expect_equal(ergebnis$z, 44 / sqrt(125))
  expect_equal(ergebnis$sen_steigung, 1)
  expect_equal(ergebnis$sen_steigung_jahrzehnt, 10)
  expect_true(ergebnis$signifikant)
})

test_that("TC-12: zehnmal der gleiche Wert ergibt kein Trend berechenbar", {
  skip_if_not_installed("trend")
  ergebnis <- expect_no_error(trendtest(rep(136, 10), parameter))
  expect_equal(ergebnis$s, 0)
  expect_equal(ergebnis$sen_steigung, 0)
  expect_true(is.na(ergebnis$p_wert))
  expect_equal(ergebnis$hinweis, "kein Trend berechenbar")
})

test_that("Reihe mit NA, zu kurze Reihe oder Text führen zu Fehlermeldung", {
  expect_error(trendtest(c(1, NA, 3, 4), parameter), "NA")
  expect_error(trendtest(c(1, 2), parameter), "mindestens 3")
  expect_error(trendtest(c("1", "2", "3"), parameter), "Zahlen")
})

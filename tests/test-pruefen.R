# Tests für R/pruefen.R

# Kleine Reihe mit je einer Auffälligkeit
testreihe <- function(hs_cm, start = "1970-12-01") {
  tibble(station_id = "TST",
         datum = as.Date(start) + seq_along(hs_cm) - 1,
         hs_cm = hs_cm, quelle = "MeteoSchweiz")
}

test_that("unauffällige Reihe ergibt keine Meldung", {
  meldungen <- pruefe_tageswerte(testreihe(c(10, 20, NA, 25)), 500, 100)
  expect_equal(nrow(meldungen), 0)
})

test_that("negative Werte, zu hohe Werte und Sprünge werden gemeldet", {
  tage <- testreihe(c(10, -5, 10, 600, 600, 450))
  meldungen <- pruefe_tageswerte(tage, obergrenze_cm = 500, sprung_cm = 100)
  expect_equal(sum(meldungen$pruefung == "negativer Wert"), 1)
  expect_equal(sum(meldungen$pruefung == "über Obergrenze"), 2)
  # Sprünge: 10 -> 600 und 600 -> 450
  expect_equal(sum(meldungen$pruefung == "Tagessprung"), 2)
})

test_that("Sprung über eine Lücke hinweg wird nicht gemeldet", {
  meldungen <- pruefe_tageswerte(testreihe(c(10, NA, 300)), 500, 100)
  expect_equal(nrow(meldungen), 0)
})

test_that("doppelte Tage werden gemeldet", {
  tage <- bind_rows(testreihe(c(10, 20)), testreihe(20, start = "1970-12-02"))
  meldungen <- pruefe_tageswerte(tage, 500, 100)
  expect_equal(sum(meldungen$pruefung == "doppelter Tag"), 2)
})

test_that("Prüfung verändert die Tageswerte nicht", {
  tage <- testreihe(c(10, -5, 600))
  kopie <- tage
  pruefe_tageswerte(tage, 500, 100)
  expect_identical(tage, kopie)
})

test_that("Datenübersicht zählt Tage mit und ohne Messwert", {
  tage <- testreihe(c(10, NA, 30), start = "1970-12-30")  # 30.12. bis 1.1.
  uebersicht <- datenuebersicht(tage, parameter$uebersicht_monate)
  expect_equal(uebersicht$jahr, c(1970L, 1971L))
  expect_equal(uebersicht$tage_mit_messwert, c(1L, 1L))
  expect_equal(uebersicht$tage_ohne_messwert, c(1L, 0L))
})

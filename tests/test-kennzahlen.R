# Tests TC-01 bis TC-10 aus Kapitel 8 der Anforderungsanalyse.
# Sie schlagen fehl, bis die Funktionen in R/kennzahlen.R geschrieben sind.
# Winter 1971 = Winter 1970/71. mache_winter() steht in helper-laden.R.

# Setzt die Schneehöhe an einzelnen Tagen
setze_tage <- function(tage, daten, hs_cm) {
  tage$hs_cm[tage$datum %in% as.Date(daten)] <- hs_cm
  tage
}

# Zehn Winter 1971 bis 1980 mit vorgegebenen Schneetagen, alle gültig
zehn_winter <- function(schneetage) {
  tibble(station_id = "TST", winter = 1971:1980, schneetage = schneetage,
         gueltig = TRUE)
}

test_that("TC-01: jeden Tag 30 cm ergibt 136 Schneetage", {
  ergebnis <- zaehle_schneetage(mache_winter(1971, 30), parameter)
  expect_equal(ergebnis$schneetage[ergebnis$winter == 1971], 136)
})

test_that("TC-02: jeden Tag 29 cm ergibt 0 Schneetage", {
  ergebnis <- zaehle_schneetage(mache_winter(1971, 29), parameter)
  expect_equal(ergebnis$schneetage[ergebnis$winter == 1971], 0)
})

test_that("TC-03: Schaltjahr 1971/72, jeden Tag 50 cm ergibt 137 Schneetage", {
  ergebnis <- zaehle_schneetage(mache_winter(1972, 50), parameter)
  expect_equal(ergebnis$schneetage[ergebnis$winter == 1972], 137)
})

test_that("TC-04: 100 cm nur am 30. November und 16. April ergibt 0", {
  tage <- setze_tage(mache_winter(1971, 0), c("1970-11-30", "1971-04-16"), 100)
  ergebnis <- zaehle_schneetage(tage, parameter)
  expect_equal(ergebnis$schneetage[ergebnis$winter == 1971], 0)
})

test_that("TC-05: 100 cm nur am 1. Dezember und 15. April ergibt 2", {
  tage <- setze_tage(mache_winter(1971, 0), c("1970-12-01", "1971-04-15"), 100)
  ergebnis <- zaehle_schneetage(tage, parameter)
  expect_equal(ergebnis$schneetage[ergebnis$winter == 1971], 2)
})

test_that("TC-06: wie TC-01 mit Saisonende 30. April ergibt 151", {
  parameter_30 <- parameter
  parameter_30$saison_ende_tag <- 30
  ergebnis <- zaehle_schneetage(mache_winter(1971, 30), parameter_30)
  expect_equal(ergebnis$schneetage[ergebnis$winter == 1971], 151)
})

test_that("TC-07: 10 Tage ohne Messwert: 92,6 %, gültig, Grenzen 126 und 136", {
  luecke <- seq(as.Date("1971-01-10"), by = "day", length.out = 10)
  tage <- setze_tage(mache_winter(1971, 30), luecke, NA)

  voll <- berechne_vollstaendigkeit(tage, parameter)
  voll <- voll[voll$winter == 1971, ]
  expect_equal(voll$tage_erwartet, 136)
  expect_equal(voll$tage_gemessen, 126)
  expect_equal(voll$vollstaendigkeit, 126 / 136)
  expect_true(voll$gueltig)

  schnee <- zaehle_schneetage(tage, parameter)
  schnee <- schnee[schnee$winter == 1971, ]
  expect_equal(schnee$schneetage, 126)
  expect_equal(schnee$schneetage_obergrenze, 136)
})

test_that("TC-08: 20 Tage ohne Messwert: 85,3 %, ungültig", {
  luecke <- seq(as.Date("1971-01-10"), by = "day", length.out = 20)
  tage <- setze_tage(mache_winter(1971, 30), luecke, NA)
  voll <- berechne_vollstaendigkeit(tage, parameter)
  voll <- voll[voll$winter == 1971, ]
  expect_equal(voll$vollstaendigkeit, 116 / 136)
  expect_false(voll$gueltig)
})

test_that("TC-09: 7 Winter mit 100 und 3 mit 99 Schneetagen: schneesicher", {
  expect_equal(ist_schneesicher(c(100, 99), parameter), c(TRUE, FALSE))
  ergebnis <- hundert_tage_regel(zehn_winter(c(rep(100, 7), rep(99, 3))),
                                 parameter)
  fenster <- ergebnis[ergebnis$winter == 1980, ]
  expect_equal(fenster$anteil_schneesicher, 0.7)
  expect_true(fenster$schneesicher)
})

test_that("TC-10: 6 Winter mit 100 und 4 mit 99 Schneetagen: nicht schneesicher", {
  ergebnis <- hundert_tage_regel(zehn_winter(c(rep(100, 6), rep(99, 4))),
                                 parameter)
  fenster <- ergebnis[ergebnis$winter == 1980, ]
  expect_equal(fenster$anteil_schneesicher, 0.6)
  expect_false(fenster$schneesicher)
})

# --- FA-14 Höhenklassen ------------------------------------------------------

test_that("FA-14: Höhenklassen mit Grenzen 1500 und 2000 m", {
  klasse <- hoehenklasse(c(958, 1499, 1500, 1878, 2000, 2001, NA),
                         parameter$hoehenklassen_grenzen,
                         parameter$hoehenklassen_namen)
  expect_equal(as.character(klasse),
               c("unter 1500 m", "unter 1500 m", "1500 bis 2000 m",
                 "1500 bis 2000 m", "1500 bis 2000 m", "über 2000 m", NA))
  expect_equal(levels(klasse), parameter$hoehenklassen_namen)
})

test_that("FA-14: falsche Eingabe führt zu Fehlermeldung", {
  expect_error(hoehenklasse("958", c(1500, 2000), c("a", "b", "c")), "Zahl")
  expect_error(hoehenklasse(958, c(1500, 2000), c("a", "b")), "Höhenklassen")
  expect_error(hoehenklasse(958, c(2000, 1500), c("a", "b", "c")), "Höhenklassen")
})

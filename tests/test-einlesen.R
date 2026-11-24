# Tests für R/einlesen.R mit kleinen künstlichen Dateien

# Legt einen leeren Ordner für die Testdateien an
neuer_testordner <- function() {
  ordner <- tempfile("skitest")
  dir.create(ordner)
  ordner
}

test_that("TC-14: fehlende Spalte führt zu klarer Fehlermeldung", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical", "TST;01.12.1970 00:00;0;0",
                     kopf = "station_abbr;reference_timestamp;rre150d0;hns000d0")
  schreibe_testdatei(ordner, "TST", "recent", "TST;01.01.1971 00:00;0;0;40")
  expect_error(lies_station_meteoschweiz("TST", ordner, parameter),
               "Spalte fehlt.*hto000d0")
})

test_that("TC-14: fehlende Datei führt zu klarer Fehlermeldung", {
  ordner <- neuer_testordner()
  expect_error(lies_station_meteoschweiz("XXX", ordner, parameter),
               "Datei nicht gefunden")
})

test_that("TC-14: unbekannte Quelle in der Stationsliste führt zu Fehler", {
  stationen <- tibble(station_id = "TST", quelle = "Unbekannt")
  expect_error(lies_alle_stationen(stationen, tempdir(), parameter),
               "keine Einlesefunktion")
})

test_that("leere Messwerte werden NA und nicht 0", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical",
                     c("TST;01.12.1970 00:00;0;0;35",
                       "TST;02.12.1970 00:00;0;0;",
                       "TST;03.12.1970 00:00;0;0;0"))
  schreibe_testdatei(ordner, "TST", "recent", "TST;04.12.1970 00:00;0;0;12")
  tage <- lies_station_meteoschweiz("TST", ordner, parameter)
  expect_equal(tage$hs_cm, c(35, NA, 0, 12))
  expect_equal(names(tage), c("station_id", "datum", "hs_cm", "quelle"))
  expect_s3_class(tage$datum, "Date")
  expect_equal(tage$datum[1], as.Date("1970-12-01"))
})

test_that("Überschneidung von historical und recent ergibt keine doppelten Tage", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical",
                     c("TST;30.12.1970 00:00;0;0;50",
                       "TST;31.12.1970 00:00;0;0;55"))
  schreibe_testdatei(ordner, "TST", "recent",
                     c("TST;31.12.1970 00:00;0;0;55",
                       "TST;01.01.1971 00:00;0;0;60"))
  tage <- suppressMessages(lies_station_meteoschweiz("TST", ordner, parameter))
  expect_equal(nrow(tage), 3)
  expect_false(any(duplicated(tage$datum)))
  expect_equal(tage$hs_cm, c(50, 55, 60))
})

test_that("doppelter Tag mit verschiedenen Werten wird gemeldet", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical", "TST;31.12.1970 00:00;0;0;55")
  schreibe_testdatei(ordner, "TST", "recent", "TST;31.12.1970 00:00;0;0;70")
  expect_warning(
    tage <- suppressMessages(lies_station_meteoschweiz("TST", ordner, parameter)),
    "verschiedenen Werten")
  expect_equal(tage$hs_cm, 55)
})

test_that("ganz fehlende Kalendertage werden als NA ergänzt", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical", "TST;01.12.1970 00:00;0;0;40")
  schreibe_testdatei(ordner, "TST", "recent", "TST;04.12.1970 00:00;0;0;44")
  tage <- suppressMessages(lies_station_meteoschweiz("TST", ordner, parameter))
  expect_equal(nrow(tage), 4)
  expect_equal(tage$hs_cm, c(40, NA, NA, 44))
})

test_that("Tage vor dem ersten Schneehöhen-Wert werden weggelassen", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical",
                     c("TST;01.12.1970 00:00;0;0;",
                       "TST;02.12.1970 00:00;0;0;",
                       "TST;03.12.1970 00:00;0;0;20",
                       "TST;04.12.1970 00:00;0;0;"))
  schreibe_testdatei(ordner, "TST", "recent", "TST;05.12.1970 00:00;0;0;25")
  expect_message(
    tage <- lies_station_meteoschweiz("TST", ordner, parameter),
    "Messbeginn Schneehöhe 03.12.1970: 2 Tag")
  expect_equal(tage$datum[1], as.Date("1970-12-03"))
  # Lücke nach dem Messbeginn bleibt NA
  expect_equal(tage$hs_cm, c(20, NA, 25))
})

test_that("Station ganz ohne Schneehöhe führt zu Fehler", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical", "TST;01.12.1970 00:00;0;0;")
  schreibe_testdatei(ordner, "TST", "recent", "TST;02.12.1970 00:00;0;0;")
  expect_error(lies_station_meteoschweiz("TST", ordner, parameter),
               "Keine Schneehöhe")
})

test_that("Text statt Zahl in der Schneehöhe führt zu Fehler", {
  ordner <- neuer_testordner()
  schreibe_testdatei(ordner, "TST", "historical", "TST;01.12.1970 00:00;0;0;abc")
  schreibe_testdatei(ordner, "TST", "recent", "TST;02.12.1970 00:00;0;0;1")
  expect_error(lies_station_meteoschweiz("TST", ordner, parameter),
               "keine Zahl")
})

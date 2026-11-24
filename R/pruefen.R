# pruefen.R
# Plausibilitätsprüfung der Tageswerte (FA-06) und Übersicht über die
# vorhandenen Messwerte. Hier wird nur gemeldet, nie korrigiert.

library(dplyr)

# Zweck:   Sucht auffällige Tageswerte: negative Werte, Werte über der
#          Obergrenze, grosse Sprünge von einem Tag zum nächsten und Tage,
#          die mehrfach vorkommen.
# Eingabe: tage (Tagesformat), obergrenze_cm, sprung_cm (aus parameter.R)
# Ausgabe: Tabelle mit einer Zeile pro Auffälligkeit (station_id, datum,
#          hs_cm, pruefung, detail); ohne Auffälligkeit hat sie 0 Zeilen.
#          Die Tageswerte selbst bleiben unverändert.
pruefe_tageswerte <- function(tage, obergrenze_cm, sprung_cm) {
  fehlend <- setdiff(c("station_id", "datum", "hs_cm", "quelle"), names(tage))
  if (length(fehlend) > 0) {
    stop("Spalte fehlt in den Tageswerten: ", paste(fehlend, collapse = ", "),
         call. = FALSE)
  }

  negativ <- tage |>
    filter(!is.na(hs_cm), hs_cm < 0) |>
    mutate(pruefung = "negativer Wert", detail = "Schneehöhe unter 0 cm")

  zu_hoch <- tage |>
    filter(!is.na(hs_cm), hs_cm > obergrenze_cm) |>
    mutate(pruefung = "über Obergrenze",
           detail = paste0("mehr als ", obergrenze_cm, " cm"))

  # Sprung: Vergleich mit dem Vortag, nur wenn beide Tage einen Messwert haben
  sprung <- tage |>
    arrange(station_id, datum) |>
    group_by(station_id) |>
    mutate(vortag_cm = lag(hs_cm),
           abstand_tage = as.numeric(datum - lag(datum))) |>
    ungroup() |>
    filter(abstand_tage == 1, !is.na(hs_cm), !is.na(vortag_cm),
           abs(hs_cm - vortag_cm) > sprung_cm) |>
    mutate(pruefung = "Tagessprung",
           detail = paste0("Vortag ", vortag_cm, " cm, Änderung ",
                           hs_cm - vortag_cm, " cm"))

  doppelt <- tage |>
    group_by(station_id, datum) |>
    filter(n() > 1) |>
    ungroup() |>
    mutate(pruefung = "doppelter Tag", detail = "Tag kommt mehrfach vor")

  bind_rows(negativ, zu_hoch, sprung, doppelt) |>
    select(station_id, datum, hs_cm, pruefung, detail) |>
    arrange(station_id, datum, pruefung)
}

# Zweck:   Zählt pro Station und Kalenderjahr die Tage mit und ohne Messwert
#          in den gewählten Monaten (Standard: Dezember bis April).
#          Das ist eine Übersicht über Lücken, nicht die Kennzahl K2.
# Eingabe: tage (Tagesformat, lückenlos), monate (Zahlen 1 bis 12)
# Ausgabe: Tabelle station_id, jahr, tage_mit_messwert, tage_ohne_messwert
datenuebersicht <- function(tage, monate) {
  tage |>
    mutate(jahr = as.integer(format(datum, "%Y")),
           monat = as.integer(format(datum, "%m"))) |>
    filter(monat %in% monate) |>
    group_by(station_id, jahr) |>
    summarise(tage_mit_messwert = sum(!is.na(hs_cm)),
              tage_ohne_messwert = sum(is.na(hs_cm)),
              .groups = "drop")
}

# einlesen.R
# Liest die Stationsliste und die Tageswerte der MeteoSchweiz und bringt sie
# in das einheitliche Tagesformat (station_id, datum, hs_cm, quelle).

library(readr)
library(dplyr)
library(tidyr)

# Zweck:   Prüft, ob eine Tabelle alle verlangten Spalten hat.
# Eingabe: tabelle (Datentabelle), spalten (Namen), herkunft (Text für die
#          Fehlermeldung, z. B. der Dateipfad)
# Ausgabe: nichts; bricht mit einer Fehlermeldung ab, wenn eine Spalte fehlt
pruefe_spalten <- function(tabelle, spalten, herkunft) {
  fehlend <- setdiff(spalten, names(tabelle))
  if (length(fehlend) > 0) {
    stop("Spalte fehlt in ", herkunft, ": ",
         paste(fehlend, collapse = ", "), call. = FALSE)
  }
}

# Zweck:   Liest die von uns gepflegte Stationsliste.
# Eingabe: pfad zu stationen.csv (Trennzeichen Strichpunkt, UTF-8)
# Ausgabe: Tabelle mit einer Zeile pro Station
lies_stationen <- function(pfad) {
  if (!file.exists(pfad)) {
    stop("Stationsliste nicht gefunden: ", pfad, call. = FALSE)
  }
  stationen <- read_delim(pfad, delim = ";", show_col_types = FALSE,
                          locale = locale(encoding = "UTF-8"))
  # Z. B. ein Strichpunkt im Bemerkungstext verschiebt die Spalten
  if (nrow(problems(stationen)) > 0) {
    stop("Stationsliste ", pfad, " hat ein falsches Format in Zeile ",
         problems(stationen)$row[1],
         " (z. B. Strichpunkt im Text oder zu viele Spalten).", call. = FALSE)
  }
  pruefe_spalten(stationen,
                 c("station_id", "station_name", "quelle", "hoehe_station_m"),
                 pfad)
  if (any(duplicated(stationen$station_id))) {
    stop("Station kommt in ", pfad, " mehrfach vor: ",
         paste(unique(stationen$station_id[duplicated(stationen$station_id)]),
               collapse = ", "), call. = FALSE)
  }
  stationen
}

# Zweck:   Liest eine einzelne Tagesdatei der MeteoSchweiz.
# Eingabe: pfad zur CSV-Datei, spalte_hs (Name der Spalte mit der Schneehöhe)
# Ausgabe: Tabelle im Tagesformat (station_id, datum, hs_cm, quelle).
#          Leere Felder werden NA. Die Einheit ist laut Parameterliste
#          bereits cm, es wird nichts umgerechnet.
lies_meteoschweiz_datei <- function(pfad, spalte_hs) {
  if (!file.exists(pfad)) {
    stop("Datei nicht gefunden: ", pfad, call. = FALSE)
  }
  # Alles als Text einlesen, damit nichts stillschweigend umgewandelt wird
  roh <- read_delim(pfad, delim = ";",
                    locale = locale(encoding = "windows-1252"),
                    col_types = cols(.default = col_character()))
  pruefe_spalten(roh, c("station_abbr", "reference_timestamp", spalte_hs), pfad)

  # Zeitstempel "dd.mm.yyyy HH:MM": nur der Tag wird gebraucht
  datum <- as.Date(roh$reference_timestamp, format = "%d.%m.%Y")
  if (any(is.na(datum))) {
    stop("Datum nicht lesbar in ", pfad, ", Zeile ",
         which(is.na(datum))[1] + 1, call. = FALSE)
  }

  # Text in Zahl umwandeln; ein Wert, der keine Zahl ist, ist ein Fehler
  text <- roh[[spalte_hs]]
  hs_cm <- suppressWarnings(as.numeric(text))
  keine_zahl <- !is.na(text) & is.na(hs_cm)
  if (any(keine_zahl)) {
    stop("Schneehöhe ist keine Zahl in ", pfad, ", Zeile ",
         which(keine_zahl)[1] + 1, ": '", text[keine_zahl][1], "'",
         call. = FALSE)
  }

  tibble(station_id = roh$station_abbr, datum = datum, hs_cm = hs_cm,
         quelle = "MeteoSchweiz")
}

# Zweck:   Entfernt Tage, die mehrfach vorkommen (Überschneidung von
#          «historical» und «recent»). Behalten wird die erste Zeile.
#          Haben die doppelten Zeilen verschiedene Werte, gibt es eine Warnung.
# Eingabe: Tabelle im Tagesformat
# Ausgabe: Tabelle im Tagesformat mit höchstens einer Zeile pro Station und Tag
entferne_doppelte_tage <- function(tage) {
  widerspruch <- tage |>
    group_by(station_id, datum) |>
    summarise(anzahl_werte = n_distinct(hs_cm), .groups = "drop") |>
    filter(anzahl_werte > 1)
  if (nrow(widerspruch) > 0) {
    warning(nrow(widerspruch), " Tag(e) doppelt mit verschiedenen Werten, ",
            "erster Wert behalten. Erster Fall: ", widerspruch$station_id[1],
            " ", format(widerspruch$datum[1]), call. = FALSE)
  }
  ohne_doppelte <- distinct(tage, station_id, datum, .keep_all = TRUE)
  entfernt <- nrow(tage) - nrow(ohne_doppelte)
  if (entfernt > 0) {
    message("  ", entfernt, " doppelte Tageszeile(n) entfernt")
  }
  ohne_doppelte
}

# Zweck:   Fügt für Kalendertage, die in der Datei ganz fehlen, eine Zeile
#          mit hs_cm = NA ein. So ist jede Lücke sichtbar.
# Eingabe: Tabelle im Tagesformat
# Ausgabe: Tabelle im Tagesformat, lückenlos vom ersten bis zum letzten Tag
ergaenze_fehlende_tage <- function(tage) {
  vollstaendig <- tage |>
    group_by(station_id, quelle) |>
    complete(datum = seq(min(datum), max(datum), by = "day")) |>
    ungroup() |>
    select(station_id, datum, hs_cm, quelle) |>
    arrange(station_id, datum)
  ergaenzt <- nrow(vollstaendig) - nrow(tage)
  if (ergaenzt > 0) {
    message("  ", ergaenzt, " fehlende Kalendertag(e) als NA ergänzt")
  }
  vollstaendig
}

# Zweck:   Liest alle Tagesdateien einer MeteoSchweiz-Station und führt sie
#          zusammen.
# Eingabe: station_id (z. B. "WHA"), ordner mit den Rohdateien, parameter
#          (Liste aus parameter.R)
# Ausgabe: Tabelle im Tagesformat, ein Tag pro Zeile, nach Datum sortiert
lies_station_meteoschweiz <- function(station_id, ordner, parameter) {
  dateien <- sprintf(parameter$ms_dateimuster, tolower(station_id),
                     parameter$ms_teile)
  teile <- lapply(file.path(ordner, dateien), lies_meteoschweiz_datei,
                  spalte_hs = parameter$ms_spalte_schneehoehe)
  tage <- bind_rows(teile)

  fremd <- setdiff(unique(tage$station_id), station_id)
  if (length(fremd) > 0) {
    stop("Dateien von ", station_id, " enthalten eine andere Station: ",
         paste(fremd, collapse = ", "), call. = FALSE)
  }
  tage |> entferne_doppelte_tage() |> ergaenze_fehlende_tage()
}

# Zweck:   Liest die Tageswerte aller Stationen der Stationsliste.
# Eingabe: stationen (aus lies_stationen), ordner_meteoschweiz, parameter
# Ausgabe: eine Tabelle im Tagesformat mit allen Stationen
lies_alle_stationen <- function(stationen, ordner_meteoschweiz, parameter) {
  unbekannt <- setdiff(unique(stationen$quelle), "MeteoSchweiz")
  if (length(unbekannt) > 0) {
    stop("Für diese Quelle gibt es noch keine Einlesefunktion: ",
         paste(unbekannt, collapse = ", "), call. = FALSE)
  }
  teile <- lapply(stationen$station_id, function(id) {
    message("Lese Station ", id)
    lies_station_meteoschweiz(id, ordner_meteoschweiz, parameter)
  })
  bind_rows(teile)
}

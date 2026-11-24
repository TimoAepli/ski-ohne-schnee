# helper-laden.R
# Wird von testthat vor allen Tests ausgeführt: lädt Parameter und Funktionen
# und stellt Hilfsfunktionen für künstliche Testdaten bereit.

source("../R/parameter.R", encoding = "UTF-8")
source("../R/einlesen.R", encoding = "UTF-8")
source("../R/pruefen.R", encoding = "UTF-8")
source("../R/kennzahlen.R", encoding = "UTF-8")

# Zweck:   Schreibt eine kleine künstliche MeteoSchweiz-Tagesdatei.
# Eingabe: ordner, station (z. B. "TST"), teil ("historical" oder "recent"),
#          zeilen (Textzeilen ohne Kopfzeile), kopf (Kopfzeile)
# Ausgabe: Pfad der geschriebenen Datei
schreibe_testdatei <- function(ordner, station, teil, zeilen,
                               kopf = "station_abbr;reference_timestamp;rre150d0;hns000d0;hto000d0") {
  pfad <- file.path(ordner, sprintf(parameter$ms_dateimuster,
                                    tolower(station), teil))
  writeLines(c(kopf, zeilen), pfad)
  pfad
}

# Zweck:   Erzeugt künstliche Tageswerte vom 1. November bis 31. Mai rund um
#          einen Winter, überall mit derselben Schneehöhe.
# Eingabe: winter (Jahr des Januars), hs_cm (Schneehöhe für jeden Tag)
# Ausgabe: Tabelle im Tagesformat für die Station "TST"
mache_winter <- function(winter, hs_cm) {
  datum <- seq(as.Date(paste0(winter - 1, "-11-01")),
               as.Date(paste0(winter, "-05-31")), by = "day")
  tibble(station_id = "TST", datum = datum, hs_cm = hs_cm,
         quelle = "MeteoSchweiz")
}

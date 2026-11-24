# webseite_bauen.R
# Zweck:   Wandelt die Shiny-Oberfläche (app.R) mit dem Paket shinylive in
#          eine statische Webseite um. R läuft dann im Browser (webR), es
#          braucht keinen R-Server. So kann GitHub Pages die App ausliefern.
#          Die Rohdaten werden hier schon eingelesen und als fertige
#          Tageswerte mitgegeben; das Einlesen im Browser wäre sehr langsam.
# Eingabe: app.R, R/, daten/manuell/stationen.csv, Tageswerte in
#          daten/roh/meteoschweiz/
# Ausgabe: Ordner webseite/ (wird committet, GitHub Pages liefert ihn aus,
#          siehe .github/workflows/pages.yml)
#
# Aufruf aus dem Projektordner: Rscript webseite_bauen.R
# Nach jeder Änderung an app.R, R/ oder den Daten neu ausführen und den
# Ordner webseite/ mitcommitten, sonst zeigt GitHub Pages den alten Stand.

if (!file.exists("app.R")) {
  stop("webseite_bauen.R muss aus dem Projektordner gestartet werden.",
       call. = FALSE)
}
if (!requireNamespace("shinylive", quietly = TRUE)) {
  stop("Paket shinylive fehlt: install.packages('shinylive')", call. = FALSE)
}

source("R/parameter.R", encoding = "UTF-8")
source("R/einlesen.R", encoding = "UTF-8")

# Zweck:   Kopiert eine Datei und legt den Zielordner bei Bedarf an.
# Eingabe: datei (Pfad relativ zum Projektordner), ziel (Zwischenordner)
# Ausgabe: keine; bricht mit Fehlermeldung ab, wenn die Datei fehlt
kopiere_datei <- function(datei, ziel) {
  if (!file.exists(datei)) {
    stop("Datei fehlt: ", datei, call. = FALSE)
  }
  zielordner <- file.path(ziel, dirname(datei))
  dir.create(zielordner, recursive = TRUE, showWarnings = FALSE)
  file.copy(datei, zielordner, overwrite = TRUE)
}

# Zweck:   Liest Stationen und Tageswerte mit denselben Funktionen wie
#          run_all.R ein und speichert sie als eine .rds-Datei.
# Eingabe: pfad (Zieldatei .rds), parameter (Liste aus parameter.R)
# Ausgabe: keine; schreibt die Datei
speichere_app_daten <- function(pfad, parameter) {
  stationen <- lies_stationen("daten/manuell/stationen.csv")
  tage <- lies_alle_stationen(stationen, "daten/roh/meteoschweiz", parameter)
  # Als gewöhnliche Tabellen speichern, damit die App readr nicht braucht
  daten <- list(stationen = as_tibble(as.data.frame(stationen)),
                tage = as_tibble(as.data.frame(tage)))
  dir.create(dirname(pfad), recursive = TRUE, showWarnings = FALSE)
  saveRDS(daten, pfad)
}

# Nur die Dateien, die die App braucht, in einen leeren Zwischenordner
# kopieren. So landen weder Tests noch Dokumente noch .git in der Webseite.
# R/einlesen.R und die Rohdaten fehlen absichtlich: Die App bekommt die
# fertigen Tageswerte (app_daten.rds) und muss online nichts einlesen.
zwischen <- file.path(tempdir(), "app_fuer_webseite")
unlink(zwischen, recursive = TRUE)
dir.create(zwischen)

dateien <- c("app.R", "R/parameter.R", "R/pruefen.R", "R/grafiken.R")
for (datei in dateien) {
  kopiere_datei(datei, zwischen)
}
speichere_app_daten(file.path(zwischen, "daten/aufbereitet/app_daten.rds"),
                    parameter)

# Alte Webseite löschen und neu erzeugen
unlink("webseite", recursive = TRUE)
shinylive::export(zwischen, "webseite")
message("Webseite gebaut: Ordner webseite/")

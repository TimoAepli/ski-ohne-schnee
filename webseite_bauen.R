# webseite_bauen.R
# Zweck:   Wandelt die Shiny-Oberfläche (app.R) mit dem Paket shinylive in
#          eine statische Webseite um. R läuft dann im Browser (webR), es
#          braucht keinen R-Server. So kann Vercel die App ausliefern.
# Eingabe: app.R, R/, daten/manuell/stationen.csv, Tageswerte in
#          daten/roh/meteoschweiz/
# Ausgabe: Ordner webseite/ (wird committet, Vercel liefert ihn aus)
#
# Aufruf aus dem Projektordner: Rscript webseite_bauen.R
# Nach jeder Änderung an app.R, R/ oder den Daten neu ausführen und den
# Ordner webseite/ mitcommitten, sonst zeigt Vercel den alten Stand.

if (!file.exists("app.R")) {
  stop("webseite_bauen.R muss aus dem Projektordner gestartet werden.",
       call. = FALSE)
}
if (!requireNamespace("shinylive", quietly = TRUE)) {
  stop("Paket shinylive fehlt: install.packages('shinylive')", call. = FALSE)
}

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

# Nur die Dateien, die die App braucht, in einen leeren Zwischenordner
# kopieren. So landen weder Tests noch Dokumente noch .git in der Webseite.
zwischen <- file.path(tempdir(), "app_fuer_webseite")
unlink(zwischen, recursive = TRUE)
dir.create(zwischen)

dateien <- c(
  "app.R",
  list.files("R", pattern = "\\.R$", full.names = TRUE),
  "daten/manuell/stationen.csv",
  list.files("daten/roh/meteoschweiz", pattern = "\\.csv$", full.names = TRUE)
)
for (datei in dateien) {
  kopiere_datei(datei, zwischen)
}

# Alte Webseite löschen und neu erzeugen
unlink("webseite", recursive = TRUE)
shinylive::export(zwischen, "webseite")
message("Webseite gebaut: Ordner webseite/")

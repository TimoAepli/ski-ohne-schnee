# run_all.R
# Startet die ganze Kette. Aufruf aus dem Projektordner: Rscript run_all.R
# Bisher: Stationen laden, Tageswerte einlesen, prüfen, Übersicht und
# Kontrollgrafiken schreiben. Kennzahlen und Trends folgen.

if (!file.exists("R/parameter.R")) {
  stop("run_all.R muss aus dem Projektordner gestartet werden.", call. = FALSE)
}

source("R/parameter.R", encoding = "UTF-8")
source("R/einlesen.R", encoding = "UTF-8")
source("R/pruefen.R", encoding = "UTF-8")
source("R/grafiken.R", encoding = "UTF-8")

# Ausgabeordner anlegen (daten/roh/ wird nie beschrieben)
for (ordner in c("daten/aufbereitet", "ausgabe/tabellen", "ausgabe/grafiken")) {
  dir.create(ordner, recursive = TRUE, showWarnings = FALSE)
}

# 1. Stationsliste und Tageswerte einlesen
stationen <- lies_stationen("daten/manuell/stationen.csv")
tage <- lies_alle_stationen(stationen, "daten/roh/meteoschweiz", parameter)
write_csv(tage, "daten/aufbereitet/tageswerte.csv", na = "")
message("Tageswerte geschrieben: ", nrow(tage), " Zeilen")

# 2. Plausibilität prüfen; Auffälligkeiten werden gemeldet, nicht korrigiert
auffaellig <- pruefe_tageswerte(tage, parameter$pruef_obergrenze_cm,
                                parameter$pruef_sprung_cm)
write_csv(auffaellig, "ausgabe/tabellen/auffaelligkeiten.csv", na = "")
message("Auffälligkeiten: ", nrow(auffaellig))
if (nrow(auffaellig) > 0) {
  print(count(auffaellig, station_id, pruefung))
}

# 3. Übersicht: Tage mit und ohne Messwert pro Kalenderjahr
uebersicht <- datenuebersicht(tage, parameter$uebersicht_monate)
write_csv(uebersicht, "ausgabe/tabellen/datenuebersicht.csv", na = "")

# 4. Kontrollgrafik pro Station
for (i in seq_len(nrow(stationen))) {
  id <- stationen$station_id[i]
  titel <- paste0("Schneehöhe ", stationen$station_name[i], " (", id, ", ",
                  stationen$hoehe_station_m[i], " m ü. M.)")
  grafik <- zeichne_schneehoehenreihe(filter(tage, station_id == id), titel)
  ggsave(file.path("ausgabe/grafiken", paste0("schneehoehe_", id, ".png")),
         grafik, width = 25, height = 12, units = "cm", dpi = 300)
}
message("Fertig.")

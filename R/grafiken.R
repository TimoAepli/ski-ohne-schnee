# grafiken.R
# Grundgerüst der Grafiken. Bisher nur die Kontrollgrafik der Rohreihe;
# die Grafiken G1 bis G10 folgen später.

library(dplyr)
library(ggplot2)

# Zweck:   Zeichnet die ganze Schneehöhenreihe einer Station. Wo Messwerte
#          fehlen, ist die Linie unterbrochen und am unteren Rand steht ein
#          oranger Strich pro fehlendem Tag.
# Eingabe: tage_station (Tagesformat, eine Station, lückenlos), titel
# Ausgabe: ggplot-Objekt
zeichne_schneehoehenreihe <- function(tage_station, titel) {
  if (all(is.na(tage_station$hs_cm))) {
    stop("Keine Messwerte zum Zeichnen: ", titel, call. = FALSE)
  }
  # Erst ab dem ersten Messwert zeichnen
  erster_tag <- min(tage_station$datum[!is.na(tage_station$hs_cm)])
  reihe <- filter(tage_station, datum >= erster_tag)
  fehlend <- filter(reihe, is.na(hs_cm))

  ggplot(reihe, aes(x = datum, y = hs_cm)) +
    geom_line(colour = "#0072B2", linewidth = 0.3, na.rm = TRUE) +
    geom_rug(data = fehlend, aes(x = datum), inherit.aes = FALSE,
             sides = "b", colour = "#D55E00") +
    scale_x_date(date_breaks = "10 years", date_labels = "%Y") +
    labs(title = titel,
         subtitle = "Orange Striche unten: Tage ohne Messwert",
         x = "Jahr", y = "Schneehöhe (cm)",
         caption = "Quelle: MeteoSchweiz") +
    theme_minimal(base_size = 11)
}

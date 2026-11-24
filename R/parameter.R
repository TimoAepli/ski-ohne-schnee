# parameter.R
# Zweck:   Alle einstellbaren Werte der Auswertung an einem Ort.
#          Im übrigen Code stehen keine festen Zahlen, sondern z. B.
#          parameter$schwellenwert_cm.
# Eingabe: keine
# Ausgabe: benannte Liste `parameter`

parameter <- list(
  # Ab dieser Schneehöhe (cm) zählt ein Tag als Schneetag
  schwellenwert_cm = 30,

  # Saisonfenster: 1. Dezember bis 15. April
  saison_beginn_monat = 12,
  saison_beginn_tag   = 1,
  saison_ende_monat   = 4,
  saison_ende_tag     = 15,

  # Erster ausgewerteter Winter. Ein Winter trägt das Jahr seines Januars:
  # Winter 1970/71 = 1971
  start_winter = 1971,

  # 100-Tage-Regel: mindestens 100 Schneetage in 7 von 10 Wintern
  min_schneetage  = 100,
  regel_winter    = 7,
  regel_fenster   = 10,

  # Ein Winter gilt als auswertbar, wenn mindestens dieser Anteil der Tage
  # im Saisonfenster einen Messwert hat
  min_vollstaendigkeit = 0.90,

  # Signifikanzniveau für die Trendtests
  signifikanzniveau = 0.05,

  # Höhenklassen: Grenzen in m ü. M. und zugehörige Bezeichnungen
  # (unter 1500 m, 1500 bis 2000 m, über 2000 m)
  hoehenklassen_grenzen = c(1500, 2000),
  hoehenklassen_namen   = c("unter 1500 m", "1500 bis 2000 m", "über 2000 m"),

  # --- Einlesen MeteoSchweiz ---
  # Spalte der täglichen Gesamtschneehöhe gemäss Parameterliste
  # (ogd-nime_meta_parameters.csv: "Schneehöhe; Morgenmessung von 6 UTC", cm)
  ms_spalte_schneehoehe = "hto000d0",
  # Dateiname pro Station: erstes %s = Kürzel klein, zweites %s = Teil
  ms_dateimuster = "ogd-nime_%s_d_%s.csv",
  ms_teile       = c("historical", "recent"),

  # --- Plausibilitätsprüfung (unsere Startwerte, nicht aus der Literatur) ---
  # Werte über dieser Schneehöhe (cm) werden gemeldet
  pruef_obergrenze_cm = 500,
  # Änderungen von einem Tag zum nächsten über diesem Betrag (cm) werden gemeldet
  pruef_sprung_cm = 100,

  # --- Datenübersicht ---
  # Monate, für die Tage mit und ohne Messwert gezählt werden
  # (1. Dezember bis 30. April)
  uebersicht_monate = c(12, 1, 2, 3, 4)
)

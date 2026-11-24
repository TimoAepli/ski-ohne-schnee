# kennzahlen.R
# Kennzahlen K1 bis K4 gemäss Kapitel 4 der Anforderungsanalyse.
# Diese Funktionen schreiben wir (Timo, Matteo, Silvan) selbst.
# Unten stehen nur die Kommentarköpfe. Die Funktionsnamen und Spalten sind
# ein Vorschlag, auf den sich die Tests in tests/test-kennzahlen.R stützen;
# wer sie ändert, passt die Tests an.
#
# Alle Schwellen und Stichtage kommen aus `parameter` (R/parameter.R).
# Winter w = 1. Dezember des Vorjahrs bis Saisonende im Jahr w.


# --- K1 Schneetage pro Winter ------------------------------------------------
# Funktion: zaehle_schneetage(tage, parameter)
# Zweck:    Zählt pro Station und Winter die Tage im Saisonfenster mit
#           mindestens parameter$schwellenwert_cm Schneehöhe.
# Eingabe:  tage      Tageswerte (station_id, datum, hs_cm, quelle)
#           parameter Liste aus parameter.R (Schwellenwert, Saisonfenster)
# Ausgabe:  Tabelle, eine Zeile pro Station und Winter:
#           station_id, winter (Jahr des Januars),
#           schneetage            Untergrenze: fehlende Tage zählen nicht
#           schneetage_obergrenze Obergrenze: fehlende Tage zählen als Schneetag


# --- K2 Vollständigkeit ------------------------------------------------------
# Funktion: berechne_vollstaendigkeit(tage, parameter)
# Zweck:    Berechnet pro Station und Winter den Anteil der Tage mit Messwert
#           an den erwarteten Tagen des Saisonfensters und kennzeichnet den
#           Winter als gültig oder ungültig.
# Eingabe:  tage      Tageswerte (station_id, datum, hs_cm, quelle)
#           parameter Liste aus parameter.R (Saisonfenster,
#                     min_vollstaendigkeit)
# Ausgabe:  Tabelle, eine Zeile pro Station und Winter:
#           station_id, winter, tage_erwartet (136, im Schaltjahr 137),
#           tage_gemessen, vollstaendigkeit (0 bis 1),
#           gueltig (TRUE, wenn vollstaendigkeit >= min_vollstaendigkeit)


# --- K3 Schneesicherer Winter ------------------------------------------------
# Funktion: ist_schneesicher(schneetage, parameter)
# Zweck:    Entscheidet, ob ein Winter schneesicher ist: mindestens
#           parameter$min_schneetage Schneetage.
# Eingabe:  schneetage Zahl oder Vektor mit Schneetagen
#           parameter  Liste aus parameter.R (min_schneetage)
# Ausgabe:  TRUE/FALSE, gleich lang wie die Eingabe


# --- K4 100-Tage-Regel im gleitenden Zehnjahresfenster -----------------------
# Funktion: hundert_tage_regel(winterwerte, parameter)
# Zweck:    Zählt für jedes Fenster aus parameter$regel_fenster
#           aufeinanderfolgenden Wintern die schneesicheren Winter. Die
#           Station gilt im Fenster als schneesicher, wenn es mindestens
#           parameter$regel_winter sind.
#           Offen (Entscheid E5): Behandlung ungültiger Winter im Fenster.
# Eingabe:  winterwerte Tabelle mit station_id, winter, schneetage, gueltig
#           parameter   Liste aus parameter.R (min_schneetage, regel_winter,
#                       regel_fenster)
# Ausgabe:  Tabelle, eine Zeile pro Station und Fenster:
#           station_id, winter (letzter Winter des Fensters),
#           anteil_schneesicher (0 bis 1), schneesicher (TRUE/FALSE)

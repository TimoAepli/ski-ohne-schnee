# Ski ohne Schnee? – Auswertungsprogramm

IDPA (BM 1, GBS St. Gallen) von Timo Aepli, Matteo Bucher und Silvan Walser.
Das Programm berechnet aus täglichen Schneehöhen Schneesicherheitskennzahlen
pro Station und Winter. Massgebend ist `docs/anforderungen.md`; bei
Widersprüchen zu dieser Datei nachfragen, nicht selbst entscheiden.

## Rollenverteilung (wichtig)

Du unterstützt, wir schreiben die Methode selbst.

- **Nicht implementieren:** die Kennzahlen K1 bis K4 (Schneetage pro Winter,
  Vollständigkeit, schneesicherer Winter, 100-Tage-Regel im gleitenden
  Zehnjahresfenster). Diese Funktionen in `R/kennzahlen.R` schreiben wir.
  Du darfst sie reviewen, Fehler benennen und Tests dafür schreiben, aber
  keine fertige Lösung liefern, ausser wir verlangen es ausdrücklich.
- **Deine Aufgaben:** Einlesen und Vereinheitlichen der Rohdaten,
  Plausibilitätsprüfungen, Tests, Grundgerüst der Grafiken, Code-Review.
- Wir lernen R gerade erst. Erkläre nach jeder Änderung in wenigen Sätzen,
  was der Code tut und warum, sodass wir es im Coachgespräch erklären können.

## Regeln für den Code

- Sprache R. Funktionsnamen, Kommentare und Grafikbeschriftungen auf Deutsch,
  Schweizer Rechtschreibung (ss statt ß).
- Erlaubte Pakete: readr, dplyr, tidyr, lubridate, ggplot2, zoo, trend,
  testthat. Weitere Pakete nur nach Rückfrage.
- `daten/roh/` wird nie verändert. Geschrieben wird nur nach
  `daten/aufbereitet/` und `ausgabe/`.
- Fehlende Messwerte sind `NA`, nie 0.
- Keine festen Werte im Code: Schwellenwert, Saisonfenster, Startwinter,
  Höhenklassen und Vollständigkeitsgrenze stehen in `R/parameter.R`.
- Auffällige Daten werden gemeldet, nicht stillschweigend korrigiert.
- Spaltennamen und Parameterkennungen der MeteoSchweiz- und SLF-Dateien aus
  den Dateien und Metadaten ablesen, nicht raten.
- Kurze Funktionen mit je einem Kommentar zu Zweck, Eingabe und Ausgabe.
  Kein Gerüst auf Vorrat (kein renv, keine YAML-Konfiguration, kein Shiny).
- Fehlende Datei, unbekannte Station oder falsches Spaltenformat führen zu
  einer klaren Fehlermeldung, nicht zu einem Resultat.

## Einheitliches Tagesformat

| Spalte     | Bedeutung                              |
|------------|----------------------------------------|
| station_id | Schlüssel zu `daten/manuell/stationen.csv` |
| datum      | Kalendertag (Date)                     |
| hs_cm      | Schneehöhe in cm, fehlend = NA         |
| quelle     | "MeteoSchweiz" oder "SLF"              |

## Ordner

```
daten/roh/          Originaldateien, unverändert
daten/manuell/      stationen.csv, wirtschaft.csv
daten/aufbereitet/  Tageswerte, Winterkennzahlen
R/                  parameter.R, einlesen.R, pruefen.R, kennzahlen.R,
                    statistik.R, grafiken.R
tests/              testthat-Tests (TC-01 bis TC-15 aus den Anforderungen)
ausgabe/            grafiken/, tabellen/
docs/               anforderungen.md, ki-protokoll.md
run_all.R           startet die ganze Kette
```

## Arbeitsweise

- Ein Arbeitspaket pro Sitzung, kleine Schritte. Vor grösseren Änderungen
  kurz den Plan nennen und auf unser OK warten.
- Nicht committen; das machen wir nach dem Durchlesen selbst.
- Am Ende jeder Sitzung einen Eintrag für `docs/ki-protokoll.md`
  vorschlagen: Datum, Zweck, Umfang (welche Dateien und Funktionen),
  zentraler Prompt. Wir brauchen das für das KI-Verzeichnis der Arbeit.

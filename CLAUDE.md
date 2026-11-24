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
  testthat, shiny, knitr, rmarkdown. Weitere Pakete nur nach Rückfrage.
- `daten/roh/` wird nie verändert. Geschrieben wird nur nach
  `daten/aufbereitet/` und `ausgabe/`, ausserdem `webseite/_site/` (nur
  durch `quarto render webseite`).
- Fehlende Messwerte sind `NA`, nie 0.
- Keine festen Werte im Code: Schwellenwert, Saisonfenster, Startwinter,
  Höhenklassen und Vollständigkeitsgrenze stehen in `R/parameter.R`.
- Auffällige Daten werden gemeldet, nicht stillschweigend korrigiert.
- Spaltennamen und Parameterkennungen der MeteoSchweiz- und SLF-Dateien aus
  den Dateien und Metadaten ablesen, nicht raten.
- Kurze Funktionen mit je einem Kommentar zu Zweck, Eingabe und Ausgabe.
  Kein Gerüst auf Vorrat (kein renv, keine YAML-Konfiguration).
- JavaScript nur als Observable JS in `webseite/interaktiv.qmd`, und dort
  nur zum Filtern und Zeichnen. Gerechnet wird ausschliesslich in R.
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
docs/               anforderungen.md, technik.md, ki-protokoll.md
README.md           Einstieg: Ziele, Stand, Schnellstart, Struktur
run_all.R           startet die ganze Kette
app.R               Shiny-Oberfläche zum Ansehen der Resultate (nur lokal)
webseite/           Quarto-Webseite (statisch): _quarto.yml, *.qmd, _laden.R;
                    gebaut nach webseite/_site/ (nicht committet)
.github/workflows/  pages.yml: baut webseite/ bei jedem Push und stellt sie
                    auf GitHub Pages
```

Lokal bauen und ansehen: `quarto preview webseite`

```text
Neue Seite: webseite/<name>.qmd anlegen und in webseite/_quarto.yml unter
navbar eintragen. Code in den Seiten ruft nur Funktionen aus R/ auf.
```

## Arbeitsweise

- Ein Arbeitspaket pro Sitzung, kleine Schritte. Vor grösseren Änderungen
  kurz den Plan nennen und auf unser OK warten.
- Committen ist erlaubt, aber nie mit dir als Autor oder Co-Autor (kein
  `Co-Authored-By`, kein anderer Autor). Kurze Commit-Messages auf
  Deutsch, eine Zeile; lieber mehrere kleine Commits, ein Thema pro Commit.
  Pushen nur, wenn wir es verlangen.
- `docs/ki-protokoll.md` nachführen: pro Sitzung ein Eintrag mit Datum,
  Zweck, Umfang (welche Dateien und Funktionen), zentralem Prompt. Wir
  brauchen das für das KI-Verzeichnis der Arbeit.

## Dokumentation nachführen (Pflicht)

Code und Dokumentation bleiben immer auf demselben Stand. Wer etwas ändert,
führt die Dokumentation im selben Arbeitsschritt und im selben oder
direkt folgenden Commit nach, nicht später.

| Änderung | Nachführen in |
|---|---|
| Funktion neu, umbenannt, entfernt oder Ein-/Ausgabe geändert | Kommentarkopf der Funktion, `docs/technik.md` Kap. 4 |
| Parameter in `R/parameter.R` | `docs/technik.md` Kap. 6 |
| Datenformat, neue Datenquelle, Rohdateien | `docs/technik.md` Kap. 5, `daten/roh/QUELLEN.md`, README «Daten und Quellen» |
| Prüfregel oder Umgang mit Lücken | `docs/technik.md` Kap. 7 |
| Ausgabedatei neu oder geändert | `docs/technik.md` Kap. 8 |
| Webseite, Workflow, Bauen | `docs/technik.md` Kap. 9, README «Verwendung» |
| Tests neu oder Stand geändert | `docs/technik.md` Kap. 10 |
| Grundsätzlicher Entscheid (Werkzeug, Aufbau, Regel) | neuer Eintrag in `docs/technik.md` Kap. 11 (Kontext – Entscheid – Folgen) |
| Arbeitspaket fertig, Station neu, Ziel geändert | README «Stand» und «Ziele» |
| Paket, Ordner, Befehl neu | README «Schnellstart»/«Projektstruktur», diese Datei |
| Offener Punkt erledigt oder neu | `docs/technik.md` Kap. 13 |

Bei jeder Änderung das Datum «Stand» oben in `docs/technik.md`
aktualisieren. Was die Anforderungsanalyse betrifft (Kennzahlen,
Rechenregeln), nicht selbst ändern, sondern nachfragen.

# Ski ohne Schnee?

[![GitHub Pages](https://github.com/TimoAepli/ski-ohne-schnee/actions/workflows/pages.yml/badge.svg)](https://github.com/TimoAepli/ski-ohne-schnee/actions/workflows/pages.yml)

Auswertungsprogramm zur Schneesicherheit in Skigebieten der Ostschweiz und
Graubündens. Es berechnet aus täglichen Schneehöhen der MeteoSchweiz
Kennzahlen pro Station und Winter und erzeugt die Tabellen und Grafiken für
unsere Interdisziplinäre Projektarbeit (IDPA, BM 1, GBS St. Gallen).

**Webseite mit den aktuellen Resultaten:**
<https://timoaepli.github.io/ski-ohne-schnee/>

## Inhalt

- [Ziele](#ziele)
- [Stand](#stand)
- [Schnellstart](#schnellstart)
- [Verwendung](#verwendung)
- [Projektstruktur](#projektstruktur)
- [Daten und Quellen](#daten-und-quellen)
- [Dokumentation](#dokumentation)
- [Arbeitsweise und KI-Einsatz](#arbeitsweise-und-ki-einsatz)
- [Team](#team)
- [Lizenz](#lizenz)

## Ziele

Das Programm liefert die Grundlagen für die Fragestellung «Ski ohne Schnee?»
mit vier Teilfragen und drei Hypothesen (Details in
[docs/anforderungen.md](docs/anforderungen.md), Kapitel 9):

| | Frage |
|---|---|
| TF1 | Wo ist die 100-Tage-Regel heute erfüllt, und wo war sie es in den ersten zehn Wintern ab 1970/71? |
| TF2 | Auf welcher Höhe liegt die Schneesicherheitsgrenze heute? |
| TF3 | Ist der Dezember stärker vom Schneemangel betroffen als der Saisonrand im Frühling? |
| TF4 | Wie wirkt sich die Schneesicherheit auf Betriebstage, Umsatz und Beschneiungsinvestitionen aus? |
| H1 | Unter 1500 m nehmen die Schneetage signifikant ab, über 2000 m nicht oder schwächer. |
| H2 | Weniger Schneesicherheit führt zu weniger Betriebstagen. |
| H3 | Je tiefer ein Gebiet liegt, desto mehr wird beschneit und desto stärker steigen die Fixkosten. |

Das Programm ist ein Werkzeug der Methode: Es rechnet nachvollziehbar und
wiederholbar, die Deutung der Resultate gehört in die schriftliche Arbeit.
Nicht im Umfang sind Zukunftsprojektionen, die Modellierung der Beschneiung
und kausale Aussagen.

**Kernbegriffe:** Ein *Schneetag* hat mindestens 30 cm Schneehöhe. Ein
Winter ist *schneesicher* mit mindestens 100 Schneetagen zwischen
1. Dezember und 15. April. Eine Station erfüllt die *100-Tage-Regel*, wenn
mindestens 7 von 10 aufeinanderfolgenden Wintern schneesicher sind.

## Stand

| Arbeitspaket | Inhalt | Stand |
|---|---|---|
| AP1–AP3 | Stationen, Projektgerüst, Einlesen und Prüfen der MeteoSchweiz-Daten | erledigt (SLF offen) |
| AP4 | Kennzahlen K1 bis K4, Höhenklassen | in Arbeit, Tests TC-01 bis TC-10 vorhanden |
| AP5–AP8 | Trends, Sensitivität, Wirtschaftsdaten, Grafiken G1 bis G10 | offen |
| Webseite | Statische Quarto-Seite mit Stationen und interaktiver Grafik | online |

Ausgewertete Stationen: Elm (958 m) und Arosa (1878 m), Schneehöhe ab 1949.

## Schnellstart

**Voraussetzungen**

- [R](https://cran.r-project.org/) (entwickelt und getestet mit 4.6.2)
- [Quarto](https://quarto.org/), nur für die Webseite (entwickelt mit 1.11)
- R-Pakete:

```r
install.packages(c("readr", "dplyr", "tidyr", "lubridate", "ggplot2",
                   "zoo", "trend", "testthat", "shiny", "knitr",
                   "rmarkdown"))
```

**Ganze Auswertung starten** (im Projektordner):

```powershell
Rscript run_all.R
```

## Verwendung

| Aufgabe | Befehl (im Projektordner) | Ergebnis |
|---|---|---|
| Auswertung | `Rscript run_all.R` | `daten/aufbereitet/`, `ausgabe/tabellen/`, `ausgabe/grafiken/` |
| Tests | `Rscript -e "testthat::test_dir('tests')"` | Testbericht in der Konsole |
| Lokale App | `Rscript -e "shiny::runApp()"` | Shiny-Oberfläche im Browser |
| Webseite ansehen | `quarto preview webseite` | Vorschau im Browser, lädt bei Änderungen neu |
| Webseite bauen | `quarto render webseite` | `webseite/_site/` |

Die öffentliche Webseite baut GitHub bei jedem Push auf `master`
automatisch neu, sobald sich `webseite/`, `R/` oder `daten/` ändern.

**Station hinzufügen:** Zeile in `daten/manuell/stationen.csv` ergänzen und
die Rohdateien nach `daten/roh/meteoschweiz/` legen (Quelle in
`daten/roh/QUELLEN.md` festhalten). Code muss nicht geändert werden.

**Einstellungen ändern:** Alle Schwellenwerte, Stichtage und Grenzen stehen
in [R/parameter.R](R/parameter.R).

## Projektstruktur

```text
ski-ohne-schnee/
├── R/                   Funktionen: parameter, einlesen, pruefen,
│                        kennzahlen, grafiken
├── daten/
│   ├── roh/             Originaldateien, werden nie verändert
│   ├── manuell/         stationen.csv (von uns gepflegt)
│   └── aufbereitet/     Tageswerte (erzeugt, nicht im Repo)
├── tests/               testthat-Tests (TC-01 bis TC-15)
├── ausgabe/             Grafiken und Tabellen (erzeugt, nicht im Repo)
├── webseite/            Quarto-Webseite (Quellen; gebaut nach _site/)
├── docs/                Anforderungen, technische Doku, KI-Protokoll
├── .github/workflows/   Bauen und Veröffentlichen der Webseite
├── run_all.R            startet die ganze Auswertung
└── app.R                lokale Shiny-Oberfläche
```

## Daten und Quellen

- **Schneehöhen:** MeteoSchweiz, Messnetz der manuellen
  Niederschlagsstationen (ogd-nime), Tageswerte. Lizenz
  [CC BY 4.0](https://opendatadocs.meteoswiss.ch/general/terms-of-use),
  verlangte Angabe: «Quelle: MeteoSchweiz».
  Dateien, Adressen und Bezugsdaten: [daten/roh/QUELLEN.md](daten/roh/QUELLEN.md).
- **Stationsliste:** von uns gepflegt, mit Begründung der Wahl pro Station.
- Geplant: SLF-Daten und Kennzahlen aus Geschäftsberichten der Bergbahnen.

## Dokumentation

| Dokument | Inhalt |
|---|---|
| [docs/anforderungen.md](docs/anforderungen.md) | Anforderungsanalyse: massgebend für Kennzahlen, Rechenregeln und Tests |
| [docs/technik.md](docs/technik.md) | Technische Dokumentation: Aufbau, Datenfluss, Funktionen, Webseite, Entscheide |
| [docs/ki-protokoll.md](docs/ki-protokoll.md) | Verzeichnis aller KI-Einsätze |
| [daten/roh/QUELLEN.md](daten/roh/QUELLEN.md) | Herkunft und Lizenz der Rohdaten |

## Arbeitsweise und KI-Einsatz

- Die Methode (Kennzahlen K1 bis K4) schreiben wir selbst. KI-Werkzeuge
  unterstützen beim Einlesen, Prüfen, Testen, bei der Webseite und beim
  Review.
- Jeder KI-Einsatz ist mit Datum, Zweck, Umfang und zentralem Prompt in
  [docs/ki-protokoll.md](docs/ki-protokoll.md) festgehalten (Grundlage für das
  KI-Verzeichnis der Arbeit).
- Regeln für Code und Zusammenarbeit: [CLAUDE.md](CLAUDE.md).

## Team

Timo Aepli, Matteo Bucher, Silvan Walser – BM 1, GBS St. Gallen.

## Lizenz

Daten der MeteoSchweiz: CC BY 4.0, «Quelle: MeteoSchweiz».
Für den eigenen Code ist noch keine Lizenz festgelegt.

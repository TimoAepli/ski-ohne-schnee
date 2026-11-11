# Datenherkunft

Alle Dateien in `daten/roh/` sind unveränderte Originale.

**Lizenz:** Creative Commons CC BY 4.0
(Nutzungsbedingungen: https://opendatadocs.meteoswiss.ch/general/terms-of-use)

**Verlangte Quellenangabe:** «Quelle: MeteoSchweiz»
(in der Dokumentation englisch: "Source: MeteoSwiss")

**Dokumentation:**
https://opendatadocs.meteoswiss.ch/a-data-groundbased/a5-manual-precipitation-stations

Hinweis: Bei Arosa (ARO) führt das Dateninventar für die Schneehöhe ab dem
16.12.2015 das WSL-Institut für Schnee- und Lawinenforschung SLF als
Dateneigner. Ob für diesen Teil eine zusätzliche Quellenangabe nötig ist,
ist noch nicht geklärt.

## Tageswerte (Messnetz ogd-nime, manuelle Niederschlagsstationen)

| Datei | Adresse | Bezugsdatum |
|-------|---------|-------------|
| meteoschweiz/ogd-nime_elm_d_historical.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/elm/ogd-nime_elm_d_historical.csv | 11.11.2026 |
| meteoschweiz/ogd-nime_elm_d_recent.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/elm/ogd-nime_elm_d_recent.csv | 11.11.2026 |
| meteoschweiz/ogd-nime_wha_d_historical.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/wha/ogd-nime_wha_d_historical.csv | 11.11.2026 |
| meteoschweiz/ogd-nime_wha_d_recent.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/wha/ogd-nime_wha_d_recent.csv | 11.11.2026 |
| meteoschweiz/ogd-nime_aro_d_historical.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/aro/ogd-nime_aro_d_historical.csv | 11.11.2026 |
| meteoschweiz/ogd-nime_aro_d_recent.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/aro/ogd-nime_aro_d_recent.csv | 11.11.2026 |

Die Dateien von Wildhaus (WHA) werden nicht mehr ausgewertet (Station nicht
in `stationen.csv`), bleiben aber als Beleg für die Datenlücke 1981 bis 1997.

«historical» reicht vom Messbeginn bis zum 31. Dezember des Vorjahrs,
«recent» vom 1. Januar des laufenden Jahres bis zum Vortag des Bezugs.

## Metadaten

| Datei | Adresse | Bezugsdatum |
|-------|---------|-------------|
| meteoschweiz/meta/ogd-nime_meta_stations.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/ogd-nime_meta_stations.csv | 11.11.2026 |
| meteoschweiz/meta/ogd-nime_meta_parameters.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/ogd-nime_meta_parameters.csv | 11.11.2026 |
| meteoschweiz/meta/ogd-nime_meta_datainventory.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-nime/ogd-nime_meta_datainventory.csv | 11.11.2026 |
| meteoschweiz/meta/ogd-smn_meta_stations.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-smn/ogd-smn_meta_stations.csv | 11.11.2026 |
| meteoschweiz/meta/ogd-smn_meta_parameters.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-smn/ogd-smn_meta_parameters.csv | 11.11.2026 |
| meteoschweiz/meta/ogd-smn_meta_datainventory.csv | https://data.geo.admin.ch/ch.meteoschweiz.ogd-smn/ogd-smn_meta_datainventory.csv | 11.11.2026 |

## Format der Dateien (gemäss Dokumentation)

- Trennzeichen Strichpunkt, Dezimalpunkt, Kodierung Windows-1252
- Zeitstempel `dd.mm.yyyy HH:MM` in UTC
- Fehlende Werte sind leere Felder
- Schneehöhe: Spalte `hto000d0` («Schneehöhe; Morgenmessung von 6 UTC»),
  Einheit cm

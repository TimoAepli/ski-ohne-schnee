# Auftrag: Projekt «Ski ohne Schnee?» aufsetzen und Einlesen bauen

Du arbeitest in einem neuen, fast leeren Ordner. Darin liegen:

- `CLAUDE.md` – Regeln für dieses Projekt. Zuerst lesen, sie gelten für alles.
- `AUFTRAG.md` – diese Datei.
- die Anforderungsanalyse als `.docx` (Dateiname beginnt mit
  «Anforderungsanalyse»).

Arbeite die Schritte 1 bis 5 der Reihe nach ab. An den drei Stellen mit
**STOPP** hältst du an, zeigst mir das Zwischenergebnis und wartest auf mein
OK. Wir lernen R gerade erst: Erkläre kurz, was du tust.

Wichtig: Die Kennzahlen K1 bis K4 schreiben wir selbst (siehe CLAUDE.md).
In diesem Auftrag kommen sie nicht vor.

---

## Schritt 1: Projektgerüst

1. Prüfe, ob `R` (`Rscript --version`), `git` und `pandoc` installiert sind.
   Fehlt etwas, sag mir, was ich installieren muss, und mach mit dem weiter,
   was ohne geht.
2. `git init`, falls noch kein Repo besteht.
3. Lege die Ordner gemäss CLAUDE.md an (`daten/roh`, `daten/manuell`,
   `daten/aufbereitet`, `R`, `tests`, `ausgabe/grafiken`, `ausgabe/tabellen`,
   `docs`).
4. `.gitignore` für R (`.Rhistory`, `.RData`, `.Rproj.user/`) und für
   `daten/aufbereitet/` und `ausgabe/`. `daten/roh/` bleibt im Repo.
5. Installiere die in CLAUDE.md erlaubten R-Pakete, soweit sie fehlen.
6. Lege `docs/ki-protokoll.md` an mit einer Tabelle: Datum, Tool und
   Version, Zweck, Umfang (Dateien/Funktionen), zentraler Prompt.
7. Lege `R/parameter.R` an mit einer benannten Liste und diesen Werten:
   Schwellenwert 30 cm; Saisonbeginn 1. Dezember; Saisonende 15. April;
   erster Winter 1970/71 (Winter = Jahr des Januars, also 1971);
   Mindestzahl Schneetage 100; Regel 7 von 10 Wintern;
   Mindestvollständigkeit 0,90; Signifikanzniveau 0,05;
   Höhenklassen unter 1500 m, 1500 bis 2000 m, über 2000 m.

## Schritt 2: Anforderungsanalyse übernehmen und bereinigen

1. Wandle die `.docx` nach `docs/anforderungen.md` um (pandoc, Tabellen als
   Markdown, Formeln lesbar). Verschiebe das Original nach `docs/`.
2. Arbeite diese Korrekturen in `docs/anforderungen.md` ein. Ändere sonst
   nichts am Inhalt.

   a. **Kapitel 1:** Den Absatz «Annahme: Mit ‹App› ist … Falls ihr eine
      interaktive App (z. B. Shiny) meint …» ersetzen durch: «Das Programm
      ist eine Skript-Pipeline in R ohne Benutzeroberfläche.»

   b. **Umfang kürzen:** NFA-06 (renv), NFA-08 (Laufzeit), FA-20, FA-26 und
      FA-30 streichen. NFA-03 und die Ordnerstruktur: Parameter stehen in
      `R/parameter.R` statt in `config.yml`. NFA-05: Git ja, aber ohne
      Commit-Kennung im Protokoll. Zähler in Kapitel 5 («Von 30
      Anforderungen …») anpassen.

   c. **K7 und FA-16:** Für Mann-Kendall und Sen-Steigung verwenden wir das
      Paket `trend`, keine eigene Implementierung. TC-11 bleibt als
      Handrechnung zur Kontrolle.

   d. **TC-12 und K7:** Bei einer Reihe ohne jede Veränderung (z. B. hohe
      Station mit dem Maximum in jedem Winter) ist die Varianz mit
      Bindungskorrektur 0 und Z nicht definiert. Erwartetes Ergebnis neu:
      S = 0, Sen-Steigung = 0, Ausgabe «kein Trend berechenbar» statt
      p-Wert, kein Abbruch.

   e. **FA-11 und T4:** «1970er-Jahre» ersetzen durch «erste zehn Winter ab
      Startwinter». Hinweis ergänzen, dass sich die Vergleichsperiode im
      Sensitivitätslauf mit dem Startwinter verschiebt.

   f. **K6 und Kapitel 9 (TF3):** Hinweis ergänzen: Tiefe Stationen haben in
      der ersten Aprilhälfte oft 0 Schneetage (Bodeneffekt), hohe im
      Dezember oft das Maximum (Deckeneffekt). Das Programm weist pro
      Station und Teilfenster den Anteil der Winter bei 0 und beim Maximum
      aus; der Vergleich ist vor allem in mittleren Lagen aussagekräftig.

   g. **K6, offen:** Die unterschriebene Projektskizze vergleicht in
      Teilfrage 3 den Dezember mit dem «Hochwinter im Februar», dieses
      Dokument mit dem April. Nichts entscheiden. Als neuen offenen
      Entscheid E11 in Kapitel 10 eintragen («Februar oder April als
      Vergleichsfenster, mit den Coaches klären, bis KW 48») und das
      Vergleichsfenster als Parameter vorsehen.

   h. **K5:** Die Spanne zwischen höchster nicht schneesicherer und tiefster
      schneesicherer Station ist das Hauptresultat, die Gerade nur
      Illustration.

   i. **Tabelle 4 (Wirtschaft):** Bei `betriebstage_weihnacht` anmerken:
      «Verfügbarkeit in Geschäftsberichten ungeprüft, sonst Interviewfrage.»

3. Erster Commit-Vorschlag: Zeig mir `git status` und eine Liste deiner
   Änderungen an der Anforderungsanalyse.

**STOPP 1** – Ich lese die Änderungen und committe selbst.

## Schritt 3: Stationskandidaten vorschlagen

Ziel: zwei Stationen für den Anfang, eine tiefe und eine hohe.

1. Lies die Dokumentation der MeteoSchweiz zu den offenen Daten:
   - https://opendatadocs.meteoswiss.ch/a-data-groundbased/a5-manual-precipitation-stations
   - https://opendatadocs.meteoswiss.ch/a-data-groundbased/a1-automatic-weather-stations

   Finde heraus, wie die Dateien heissen und wo sie liegen (Stationsliste,
   Parameterliste, Dateninventar, Tageswerte «historical» und «recent»).
   Nichts raten: Wenn du eine Adresse oder Kennung nicht belegen kannst,
   frag mich.
2. Lade Stationsliste, Parameterliste und Dateninventar nach
   `daten/roh/meteoschweiz/meta/`.
3. Bestimme die Kennung des Parameters für die tägliche Gesamtschneehöhe
   und ihre Einheit. Zitiere mir die Zeile aus der Parameterliste.
4. Filtere Stationen in den Kantonen SG, AR, AI, GL und GR, die diesen
   Parameter seit spätestens Dezember 1970 führen. Zeig mir eine Tabelle:
   Kürzel, Name, Kanton, Höhe, Messbeginn, Messende. Speichere sie als
   `ausgabe/tabellen/stationskandidaten.csv`.
5. Schlag je zwei Kandidaten unter 1500 m und über 1800 m vor, die nahe bei
   einem Skigebiet liegen, und begründe kurz.

**STOPP 2** – Ich wähle zwei Stationen.

## Schritt 4: Einlesen und Prüfen (FA-01, FA-03, FA-05 bis FA-07 ohne K2)

Nenn mir zuerst in fünf Sätzen deinen Plan. **STOPP 3** – dann:

1. Lade die Tageswerte der zwei gewählten Stationen («historical» und
   «recent») nach `daten/roh/meteoschweiz/`. Halte in
   `daten/roh/QUELLEN.md` fest: Datei, Adresse, Bezugsdatum, Lizenz,
   verlangte Quellenangabe.
2. Lege `daten/manuell/stationen.csv` mit den Feldern aus Tabelle 1 der
   Anforderungsanalyse an und trage die zwei Stationen ein. Felder, die du
   nicht belegen kannst (Skigebiet, Bergbahn, Distanz), leer lassen.
3. `R/einlesen.R`: Funktion, die die Dateien einer Station einliest,
   «historical» und «recent» zusammenführt, doppelte Tage entfernt und das
   einheitliche Tagesformat liefert (`station_id`, `datum`, `hs_cm`,
   `quelle`). Einheit nach cm umrechnen, falls nötig. Fehlend = `NA`.
4. `R/pruefen.R`: Funktion, die negative Werte, Werte über einer
   einstellbaren Obergrenze, Tagessprünge über einem einstellbaren Betrag
   und doppelte Tage meldet. Nichts korrigieren. Die Grenzen kommen nach
   `R/parameter.R`.
5. Tests in `tests/` mit kleinen künstlichen Dateien: fehlende Spalte führt
   zu klarer Fehlermeldung (TC-14), leere Messwerte werden `NA` und nicht 0,
   Überschneidung von «historical» und «recent» ergibt keine doppelten
   Tage.
6. `run_all.R`: liest alle Stationen aus `stationen.csv`, prüft sie und
   schreibt die Tageswerte nach `daten/aufbereitet/tageswerte.csv`.
7. Übersicht pro Station nach `ausgabe/tabellen/datenuebersicht.csv`:
   pro Kalenderjahr die Anzahl Tage mit und ohne Messwert zwischen
   1. Dezember und 30. April. Dazu pro Station ein Plot der ganzen
   Schneehöhenreihe als PNG in `ausgabe/grafiken/`, fehlende Abschnitte
   sichtbar.
8. Lass `run_all.R` und die Tests laufen und zeig mir die Ausgabe.

## Schritt 5: Abschluss

1. Fasse zusammen: Was steht, was ist auffällig an den Daten (besonders
   Lücken zwischen 1981 und 1997), was ist offen.
2. Erkläre mir `R/einlesen.R` und `R/pruefen.R` Abschnitt für Abschnitt.
3. Schlag den Eintrag für `docs/ki-protokoll.md` vor.
4. Lege `R/kennzahlen.R` nur als leere Datei mit Kommentarköpfen für K1
   bis K4 an (Zweck, Eingabe, Ausgabe gemäss Kapitel 4 der
   Anforderungsanalyse) und schreib die Tests TC-01 bis TC-10 in `tests/`.
   Die Tests dürfen fehlschlagen: Die Funktionen schreiben wir.

Nicht in diesem Auftrag: SLF-Daten, Trends, Sensitivität, Wirtschaftsdaten,
Grafiken G1 bis G10.

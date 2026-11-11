# KI-Protokoll

Verzeichnis aller Einsätze von KI-Werkzeugen in diesem Projekt
(Grundlage für das KI-Verzeichnis der IDPA).

| Datum | Tool und Version | Zweck | Umfang (Dateien/Funktionen) | Zentraler Prompt |
|-------|------------------|-------|-----------------------------|------------------|
| 11.11.2026 | Claude Code (Claude Fable 5.2) | Projekt aufsetzen, Anforderungsanalyse nach Markdown umwandeln und bereinigen, Stationskandidaten bestimmen und ihre Lücken auswerten, Einlesen und Prüfen der MeteoSchweiz-Tageswerte | `R/parameter.R`, `R/einlesen.R` (alle Funktionen), `R/pruefen.R` (alle Funktionen), `R/grafiken.R` (`zeichne_schneehoehenreihe`), `run_all.R`, `tests/` (alle Dateien), `docs/anforderungen.md` (Korrekturen a bis i), `daten/roh/QUELLEN.md`, `daten/manuell/stationen.csv` (Wildhaus durch Elm ersetzt), `.gitignore`; Tabellen `stationskandidaten.csv` und `stationskandidaten_luecken.csv` in `ausgabe/tabellen/`; erster Commit und Push. `R/kennzahlen.R` nur Kommentarköpfe, K1 bis K4 ohne KI | «Lies CLAUDE.md und AUFTRAG.md und arbeite den Auftrag Schritt für Schritt ab.» (Wortlaut des Auftrags in `AUFTRAG.md`) |

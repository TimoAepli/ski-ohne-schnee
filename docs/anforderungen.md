# Anforderungsanalyse – Auswertungsprogramm «Ski ohne Schnee?»

Nov 11, 2026 · @Matteo

## 1 Zweck und Abgrenzung

Das Programm berechnet aus täglichen Schneehöhen pro Station und Winter die Schneesicherheitskennzahlen und liefert alle Tabellen und Grafiken, die wir für die Teilfragen 1 bis 4 und die Hypothesen H1 bis H3 brauchen. Es ist ein Werkzeug der Methode, nicht das Produkt der IDPA: Bewertet wird die schriftliche Arbeit.

Das Programm ist eine Skript-Pipeline in R. Dazu kommt eine lokale Oberfläche mit dem Paket `shiny`, in der man die Resultate ansehen kann (FA-31).

**Im Umfang**

- Rohdaten von MeteoSchweiz und SLF einlesen, vereinheitlichen und auf Qualität prüfen

- Schneetage, 100-Tage-Regel, Schneesicherheitsgrenze sowie Dezember- und Aprilkennzahlen berechnen

- Trends testen (Mann-Kendall) und Zusammenhänge prüfen (Streudiagramme, Korrelation, lineare Regression)

- Manuell erfasste Kennzahlen aus Geschäftsberichten einlesen und mit den Schneedaten verknüpfen

- Sensitivitätsanalysen zu Stichtag und Startjahr rechnen

- Grafiken und Tabellen in druckfähiger Qualität exportieren

- Lokale Oberfläche (Shiny) zum Ansehen der Resultate

**Nicht im Umfang**

- Automatisches Auslesen von Geschäftsberichten (PDF): Die Zahlen erfassen wir von Hand in einer CSV-Datei

- Zukunftsprojektionen oder Schneemodelle: Dafür stützen wir uns auf die Literatur (Marty et al., 2017)

- Modellierung der technischen Beschneiung

- Im Internet veröffentlichte Webanwendung (die Shiny-Oberfläche läuft nur lokal), Datenbank

- Kausale Aussagen: Das Programm liefert Zusammenhänge, die Deutung gehört in die Diskussion

## 2 Stakeholder und Rahmenbedingungen

Die Anforderungen kommen aus vier Richtungen: unseren Fragestellungen, den Vorgaben der Coaches, dem Bewertungsraster und dem KI-Leitfaden.

| Stakeholder | Interesse am Programm |
|----|----|
| Gruppe (Timo, Matteo, Silvan) | Korrekte, erklärbare Resultate; wenig Handarbeit bei Änderungen an Stationen oder Parametern |
| Christine Meyer (Umwelt und Technik) | Fachlich saubere Kennzahlen, Vergleich tiefe und hohe Gebiete, Heatmap der Betriebstage |
| David Schiess (Mathematik) | Grafische Analyse zuerst, Korrelation als Mass, nachvollziehbare Statistik, relative statt absolute Finanzzahlen |
| Lesende der Arbeit | Verständliche Grafiken, überprüfbare Zahlen |

| Vorgabe | Quelle | Folge für das Programm |
|----|----|----|
| Methoden begründen und in der konkreten Ausgestaltung erläutern | Bewertungsraster E4 | Jede Rechenregel ist dokumentiert und als Parameter sichtbar (Kapitel 4) |
| Methoden sorgfältig durchführen, Ergebnisse stimmig integrieren | Bewertungsraster E5 | Tests und Plausibilitätsprüfungen (Kapitel 8) |
| Einflussfaktoren berücksichtigen, Erkenntnisgewinn einschätzen | Bewertungsraster E6 | Sensitivitätsanalysen, Ausweis von Datenlücken |
| Diagramme zweckdienlich und in den Text integriert | Bewertungsraster I2 | Einheitlicher Grafikstil, Export in Druckqualität |
| Rohdatentabellen strukturiert im Anhang | Bewertungsraster I3 | Export der Kennzahlentabellen; Code und Rohdaten als Anhang oder Ablage |
| KI-Einsatz in Einleitung und KI-Verzeichnis im Anhang deklarieren | Leitfaden KI, Kap. 4.2 | KI-Hilfe beim Programmieren laufend protokollieren (Zweck, Umfang, zentrale Prompts) |
| Coaches können Prozessdokumentation verlangen | Leitfaden KI, Kap. 4.8 | Versionsverlauf (Git) und Zwischenstände aufbewahren |
| Keine Geschäftsgeheimnisse in KI-Systeme eingeben | Leitfaden KI, Kap. 4.7 | Nur publizierte Geschäftszahlen verwenden; vertrauliche Interviewangaben nicht in KI-Tools |
| Auswertung in R, Open Source, private Hardware | Projektskizze | Keine kostenpflichtige Software, keine Cloud-Abhängigkeit |
| Schneedaten unter CC BY 4.0 | Projektskizze | Quellenangabe pro Datensatz mit Bezugsdatum festhalten |

Termine: erste Resultate bis KW 47, Coachgespräch zu Datengrundlage und Methodik in KW 50, Rohfassung in KW 3, Abgabe in KW 7 2027.

Hinweis: Kapitel 4.5 des KI-Leitfadens (Programmdateien bis zur Diplomübergabe aufbewahren) ist für gestalterische digitale Arbeiten formuliert. Ob es für unser Auswertungsprogramm gilt, ist nicht eindeutig. Wir bewahren Code und Zwischenresultate trotzdem auf und klären es im Coachgespräch KW 50.

## 3 Datenquellen und Datenmodell

Das Programm arbeitet mit drei Eingaben: täglichen Schneehöhen, einer von uns gepflegten Stationsliste und einer von Hand erfassten Tabelle mit Geschäftszahlen.

| Quelle | Inhalt | Format und Zugang | Stand der Abklärung |
|----|----|----|----|
| [MeteoSchweiz, manuelle Niederschlagsstationen (ogd-nime)](https://opendatadocs.meteoswiss.ch/a-data-groundbased/a5-manual-precipitation-stations) | Tageswerte; rund 240 Standorte, davon etwa 190 mit Regen und Schnee und etwa 50 nur mit Schnee | CSV, eine Datei pro Station mit allen Parametern; Dateien «historical» und «recent»; Metadaten zu Parametern, Stationen und Dateninventar | Dokumentation geprüft. Kennung des Parameters Schneehöhe und Messbeginn pro Station noch aus den Metadaten-Dateien auslesen |
| [MeteoSchweiz, automatische Wetterstationen (ogd-smn)](https://opendatadocs.meteoswiss.ch/a-data-groundbased/a1-automatic-weather-stations) | Tageswerte, rund 160 Stationen | CSV pro Station, gleiche Struktur | Ob und seit wann die gewählten Stationen Schneehöhe führen, ist offen |
| SLF-Datenservice | Tägliche Schneehöhen der SLF-Messfelder | Noch nicht geprüft | Format, Stationskennungen und Lizenztext vor dem Programmieren des Einlesens klären |
| Geschäftsberichte der Bergbahnen | Betriebstage, Umsatz, Beschneiungsinvestitionen | PDF, manuelle Erfassung in CSV | Verfügbarkeit pro Bergbahn und Jahr offen |

Zwei Punkte aus der MeteoSchweiz-Dokumentation betreffen uns direkt. Erstens verlangt sie die Quellenangabe «Quelle: MeteoSchweiz». Zweitens empfiehlt sie für Klimaanalysen die homogenen Messreihen statt der Rohmesswerte. Ob es für die Schneehöhe homogene Reihen gibt, haben wir nicht geprüft; falls nein, gehört das als Einschränkung in die Methodenkritik.

**Tabelle 1: Stationsliste** (stationen.csv, von uns gepflegt)

| Feld                      | Bedeutung                                     |
|---------------------------|-----------------------------------------------|
| gebiet                    | Name des Skigebiets                           |
| bergbahn                  | Unternehmen, Schlüssel zur Wirtschaftstabelle |
| region                    | Ostschweiz oder Graubünden                    |
| station_id, station_name  | Kennung und Name gemäss Datenlieferant        |
| quelle                    | MeteoSchweiz oder SLF                         |
| hoehe_station_m           | Höhe der Messstation                          |
| hoehe_tal_m, hoehe_berg_m | Tiefster und höchster Punkt des Skigebiets    |
| distanz_km                | Distanz Station zu Skigebiet                  |
| bemerkung                 | Begründung der Stationswahl, Standortwechsel  |

**Tabelle 2: Tageswerte** (einheitliches Zwischenformat nach dem Einlesen)

| Feld       | Bedeutung                             |
|------------|---------------------------------------|
| station_id | Schlüssel zur Stationsliste           |
| datum      | Kalendertag                           |
| hs_cm      | Schneehöhe in cm; fehlend = NA, nie 0 |
| quelle     | Herkunft des Werts                    |

**Tabelle 3: Winterkennzahlen** (Ausgabe, eine Zeile pro Station und Winter)

| Feld | Bedeutung |
|----|----|
| winter | Jahr des Januars, z. B. 1971 für den Winter 1970/71 |
| tage_erwartet, tage_gemessen, vollstaendigkeit | Grundlage für die Gültigkeit des Winters |
| schneetage | Tage mit mindestens 30 cm im Saisonfenster |
| schneetage_dez, schneetage_weihnacht, schneetage_apr | Teilfenster für Teilfrage 3 und die Vorgabe zu den Weihnachtstagen |
| gueltig | Winter erfüllt die Vollständigkeitsregel |

**Tabelle 4: Wirtschaft** (wirtschaft.csv, von Hand erfasst)

| Feld | Bedeutung |
|----|----|
| bergbahn, geschaeftsjahr, winter | Zuordnung des Geschäftsjahrs zum Winter ausdrücklich festhalten |
| betriebstage_winter, betriebstage_weihnacht | Zentrale Kennzahl gemäss Coachgespräch. Zu betriebstage_weihnacht: Verfügbarkeit in Geschäftsberichten ungeprüft, sonst Interviewfrage. |
| umsatz_chf, gewinn_chf | Für relative Kennzahlen (Index, Anteil) |
| invest_beschneiung_chf, anteil_beschneit_pct | Für H3 |
| quelle, seite | Geschäftsbericht und Seitenzahl, damit jeder Wert belegt ist |

Offen: Geschäftsjahre der Bergbahnen enden nicht einheitlich. Vor der Erfassung pro Bergbahn klären, welcher Winter in welchem Geschäftsjahr liegt.

## 4 Kennzahlen und Rechenregeln

Jede Kennzahl ist hier so definiert, dass wir sie von Hand nachrechnen können; alle Schwellenwerte sind Parameter in einer Konfigurationsdatei und stehen nirgends fest im Code.

| Parameter | Standardwert | Variante für Sensitivitätstest |
|----|----|----|
| Schwellenwert Schneehöhe | 30 cm (festgelegt) | keine |
| Saisonbeginn | 1\. Dezember | keine |
| Saisonende | 15\. April | 30\. April |
| Erster Winter | 1970/71 | 1971/72, 1975/76 |
| Mindestzahl Schneetage | 100 | keine |
| Regel im Zehnjahresfenster | 7 von 10 Wintern | keine |
| Mindestvollständigkeit pro Winter | 90 % (unser Vorschlag, nicht aus der Literatur) | 80 %, 95 % |
| Signifikanzniveau | 5 % | keine |
| Vergleichsfenster zu Dezember (Teilfrage 3) | April, 1. bis 15. April (offen, siehe E11) | Februar |

**K1 Schneetage pro Winter.** Der Winter w dauert vom 1. Dezember des Vorjahrs bis zum 15. April des Jahres w. Das sind 31 + 31 + 28 + 31 + 15 = 136 Tage, in Schaltjahren 137. Mit Saisonende 30. April sind es 151 bzw. 152 Tage.

$$S_{s,w} = \sum_{d \in \text{Winter } w} \mathbf{1}\left[ HS_{s,d} \ge 30\,\text{cm} \right]$$

**K2 Vollständigkeit.** Anteil der Tage mit Messwert an den erwarteten Tagen. Winter unter der Mindestvollständigkeit gelten als ungültig und fliessen nicht in Trends ein. Für gültige Winter mit einzelnen Lücken weist das Programm zwei Werte aus: eine Untergrenze (fehlende Tage zählen nicht als Schneetag) und eine Obergrenze (fehlende Tage zählen als Schneetag). Liegen beide auf derselben Seite von 100, ist das Urteil eindeutig.

**K3 Schneesicherer Winter.** Ein Winter ist schneesicher, wenn S mindestens 100 beträgt.

**K4 100-Tage-Regel im gleitenden Fenster.** Für jedes Fenster aus zehn aufeinanderfolgenden Wintern zählt das Programm die schneesicheren Winter. Die Station gilt im Fenster als schneesicher, wenn es mindestens 7 sind. Offen ist die Behandlung ungültiger Winter im Fenster; Vorschlag: Fenster nur werten, wenn mindestens 8 Winter gültig sind, und dann den Anteil von 70 % verlangen.

$$A_{s,w} = \frac{1}{10} \sum_{k=w-9}^{w} \mathbf{1}\left[ S_{s,k} \ge 100 \right], \qquad \text{schneesicher, wenn } A_{s,w} \ge 0{,}7$$

**K5 Schneesicherheitsgrenze (Teilfrage 2).** Pro Periode trägt das Programm den Anteil schneesicherer Winter gegen die Stationshöhe auf und legt eine Gerade A = a + b·h hindurch. Die Grenze ist die Höhe, bei der die Gerade 0,7 erreicht. Bei nur fünf Stationen ist dieser Wert unsicher. Das Hauptresultat ist deshalb die Spanne zwischen der höchsten nicht schneesicheren und der tiefsten schneesicheren Station; die Gerade dient nur der Illustration.

$$h^{*} = \frac{0{,}7 - a}{b}$$

**K6 Saisonränder (Teilfrage 3).** Dezember = 1. bis 31. Dezember (31 Tage), April = 1. bis 15. April (15 Tage). Weil die Fenster ungleich lang sind, vergleicht das Programm Anteile statt Tage, also Schneetage geteilt durch Fensterlänge, und den Trend in Prozentpunkten pro Jahrzehnt. Das Fenster «Weihnachtstage» ist noch zu definieren (Vorschlag: 24. Dezember bis 2. Januar; mit den Coaches abstimmen).

Hinweis zu Boden- und Deckeneffekt: Tiefe Stationen haben in der ersten Aprilhälfte oft 0 Schneetage (Bodeneffekt), hohe im Dezember oft das Maximum (Deckeneffekt). Das Programm weist pro Station und Teilfenster den Anteil der Winter bei 0 und beim Maximum aus; der Vergleich ist vor allem in mittleren Lagen aussagekräftig.

Offen (E11): Die unterschriebene Projektskizze vergleicht in Teilfrage 3 den Dezember mit dem «Hochwinter im Februar», dieses Dokument mit dem April. Der Entscheid steht aus. Das Vergleichsfenster ist deshalb ein Parameter und steht nicht fest im Code.

**K7 Trend (Mann-Kendall und Sen-Steigung).** Der Test vergleicht jedes Wertepaar der Zeitreihe und zählt, ob der spätere Wert grösser oder kleiner ist. S nahe 0 bedeutet kein Trend. Aus S und seiner Varianz folgt die Testgrösse Z und daraus der p-Wert. Die Sen-Steigung ist der Median aller paarweisen Steigungen und gibt die Stärke des Trends in Tagen pro Jahr an.

$$S = \sum_{i<j} \operatorname{sgn}(x_j - x_i), \qquad \operatorname{Var}(S) = \frac{n(n-1)(2n+5)}{18}, \qquad Z = \frac{S \mp 1}{\sqrt{\operatorname{Var}(S)}}$$

$$\beta = \operatorname{median}\left( \frac{x_j - x_i}{j - i} \right), \quad i < j$$

Die Varianzformel gilt ohne gleiche Werte. Bei Tageszählungen kommen gleiche Werte häufig vor, deshalb muss das Programm die Korrektur für Bindungen verwenden. Die Herleitung der Korrektur haben wir noch nicht mit einer Quelle belegt.

Umsetzung: Für Mann-Kendall-Test und Sen-Steigung verwenden wir das R-Paket `trend`, keine eigene Implementierung. Die Formeln oben dienen dem Verständnis und der Handrechnung zur Kontrolle (TC-11).

Sonderfall Reihe ohne jede Veränderung (z. B. hohe Station mit dem Maximum in jedem Winter): Die Varianz mit Bindungskorrektur ist dann 0 und Z nicht definiert. Das Programm gibt in diesem Fall S = 0, Sen-Steigung = 0 und statt eines p-Werts «kein Trend berechenbar» aus und bricht nicht ab (TC-12).

**K8 Zusammenhänge.** Pearson-Korrelation r für die Stärke eines linearen Zusammenhangs, lineare Regression y = a + b·x mit Bestimmtheitsmass R². Vor jeder Rechnung steht das Streudiagramm (Vorgabe Coachgespräch).

$$r = \frac{\sum (x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum (x_i - \bar{x})^2 \, \sum (y_i - \bar{y})^2}}$$

**K9 Relative Wirtschaftskennzahlen.** Umsatz und Gewinn werden nicht in Franken verglichen, sondern als Index (Basisjahr = 100), als Abweichung vom eigenen Mehrjahresmittel in Prozent und als Beschneiungsinvestitionen in Prozent des Umsatzes. Betriebstage können direkt verglichen werden.

**Zwei Fallen, die das Programm sichtbar machen muss**

- Deckeneffekt: Eine Station über 2000 m erreicht in fast jedem Winter das Maximum von 136 Schneetagen. Die Kennzahl kann dort gar nicht abnehmen. «Keine Abnahme über 2000 m» in H1 wäre dann teilweise ein Artefakt der Kennzahl. Das Programm weist deshalb pro Station den Anteil der Winter am Maximum aus und berechnet als Kontrolle die mittlere Schneehöhe im Saisonfenster.

- Fixkosten pro Betriebstag (H3): Geschäftsberichte weisen Fixkosten in der Regel nicht separat aus. Wir müssen festlegen, welche Positionen wir als Fixkosten zählen, bevor wir H3 prüfen können. Das ist offen.

## 5 Funktionale Anforderungen

Von 28 Anforderungen sind 22 Muss, 4 Soll und 2 Kann; die Muss-Anforderungen reichen, um alle vier Teilfragen zu beantworten. Der Ablauf ist eine gerade Kette, die mit einem einzigen Befehl durchläuft:

1.  Konfiguration und Stationsliste laden

2.  Rohdaten einlesen und in das einheitliche Tagesformat bringen

3.  Qualität prüfen und Vollständigkeit pro Winter berechnen

4.  Winterkennzahlen berechnen

5.  100-Tage-Regel, Schneesicherheitsgrenze und Saisonränder auswerten

6.  Trends testen

7.  Wirtschaftsdaten laden und mit den Winterkennzahlen verknüpfen

8.  Sensitivitätsläufe rechnen

9.  Grafiken, Tabellen und Laufprotokoll exportieren

**Einlesen und Aufbereiten**

| ID | Anforderung | Priorität | Bezug |
|----|----|----|----|
| FA-01 | Tageswerte der MeteoSchweiz aus den CSV-Dateien pro Station einlesen (historical und recent zusammenführen, Überschneidungen entfernen) | Muss | alle |
| FA-02 | Tageswerte aus dem SLF-Datenservice einlesen | Muss | alle |
| FA-03 | Beide Quellen in das einheitliche Format station_id, datum, hs_cm, quelle bringen; Einheit cm, Datum als Kalendertag | Muss | alle |
| FA-04 | Stationsliste aus stationen.csv laden; Stationen hinzufügen oder entfernen ohne Codeänderung | Muss | alle |
| FA-05 | Fehlende Werte als NA führen, nie als 0 | Muss | alle |
| FA-06 | Plausibilitätsprüfung: negative Werte, Werte über einer Obergrenze, Sprünge von mehr als einem einstellbaren Betrag pro Tag, doppelte Tage; Auffälligkeiten ins Protokoll, nicht stillschweigend korrigieren | Muss | E5 |
| FA-07 | Vollständigkeit pro Station und Winter berechnen und Winter als gültig oder ungültig kennzeichnen (K2) | Muss | Datenlücke 1981–1997 |
| FA-08 | Zwei Reihen derselben Station (MeteoSchweiz und SLF) nur zusammenführen, wenn ein Überlappungszeitraum geprüft wurde; Abweichung im Protokoll ausweisen | Soll | Datenlücke 1981–1997 |

**Schneekennzahlen**

| ID | Anforderung | Priorität | Bezug |
|----|----|----|----|
| FA-09 | Schneetage pro Station und Winter berechnen (K1), mit Unter- und Obergrenze bei Lücken | Muss | TF1, H1 |
| FA-10 | Schneesichere Winter bestimmen (K3) und 100-Tage-Regel im gleitenden Zehnjahresfenster auswerten (K4) | Muss | TF1 |
| FA-11 | Vergleich zweier Perioden pro Station: erste zehn Winter ab Startwinter und letzte zehn Winter. Die Vergleichsperiode verschiebt sich im Sensitivitätslauf mit dem Startwinter | Muss | TF1 |
| FA-12 | Schneesicherheitsgrenze pro Periode berechnen, mit Spanne (K5) | Muss | TF2 |
| FA-13 | Schneetage für Dezember, Weihnachtstage und April getrennt berechnen, als Anteil der Fensterlänge (K6) | Muss | TF3 |
| FA-14 | Stationen in Höhenklassen einteilen (unter 1500 m, 1500 bis 2000 m, über 2000 m); Klassengrenzen als Parameter | Muss | H1 |
| FA-15 | Deckeneffekt ausweisen: Anteil der Winter am Maximum pro Station; mittlere Schneehöhe im Saisonfenster als Kontrollgrösse | Soll | H1 |

**Statistik**

| ID | Anforderung | Priorität | Bezug |
|----|----|----|----|
| FA-16 | Mann-Kendall-Test mit Bindungskorrektur und Sen-Steigung pro Station und pro Teilfenster, gerechnet mit dem R-Paket `trend` (keine eigene Implementierung); Ausgabe von S, Z, p-Wert, Steigung pro Jahrzehnt, Anzahl Winter (K7) | Muss | H1, TF3 |
| FA-17 | Streudiagramm-Matrix aller Variablenpaare mit Korrelationskoeffizient (K8) | Muss | Coachgespräch |
| FA-18 | Lineare Regression für gewählte Variablenpaare mit Steigung, Achsenabschnitt, R² und p-Wert | Muss | H2, H3, TF4 |
| FA-19 | Sensitivitätslauf: alle Kennzahlen und Trends zusätzlich mit Saisonende 30. April und mit Startwinter 1971/72 und 1975/76; Ergebnis als Vergleichstabelle | Muss | offene Entscheide |
| FA-21 | Spearman-Rangkorrelation als Ergänzung bei wenigen Datenpunkten | Kann | H3 |

**Wirtschaft**

| ID | Anforderung | Priorität | Bezug |
|----|----|----|----|
| FA-22 | wirtschaft.csv laden und prüfen: Pflichtfelder, Wertebereiche, jede Zeile mit Quelle und Seite | Muss | TF4 |
| FA-23 | Wirtschaftsdaten über Bergbahn und Winter mit den Winterkennzahlen verknüpfen | Muss | TF4, H2 |
| FA-24 | Relative Kennzahlen berechnen: Index, Abweichung vom Mittel, Beschneiungsinvestitionen in Prozent des Umsatzes (K9) | Muss | Coachgespräch |
| FA-25 | Gegenüberstellung tiefe und hohe Gebiete: Differenz der Betriebstage pro Winter und mögliche erklärende Variablen | Soll | Coachgespräch |

**Ausgabe**

| ID | Anforderung | Priorität | Bezug |
|----|----|----|----|
| FA-27 | Alle Grafiken aus Kapitel 7 als PDF und PNG exportieren, einheitlicher Stil | Muss | I2 |
| FA-28 | Kennzahlentabellen als CSV exportieren | Muss | I3 |
| FA-29 | Laufprotokoll schreiben: Datum, Parameter, Stationen, Datenstand, Anzahl gültige Winter, Auffälligkeiten | Soll | E4, E5 |
| FA-31 | Lokale Oberfläche mit Shiny zum Ansehen der Resultate; sie verwendet dieselben Funktionen wie die Pipeline und rechnet nichts eigenes | Kann | Coachgespräch |

Nicht nummeriert, aber offen: FA-25 braucht Betriebstage für mindestens ein tiefes und ein hohes Gebiet über mehrere Jahre. Ob die Geschäftsberichte das hergeben, wissen wir erst nach der Sichtung.

## 6 Nichtfunktionale Anforderungen

Das wichtigste Qualitätsmerkmal ist Reproduzierbarkeit: Wer Rohdaten, Konfiguration und Code hat, erhält dieselben Zahlen und Grafiken wie in der Arbeit.

| ID | Anforderung | Messbar an |
|----|----|----|
| NFA-01 | Reproduzierbarkeit: Ein Befehl erzeugt alle Resultate neu aus den Rohdaten | Zweiter Lauf auf einem anderen Rechner liefert identische Kennzahlentabellen |
| NFA-02 | Rohdaten sind unveränderlich: Das Programm schreibt nie in den Ordner mit den Originaldateien | Ordner schreibgeschützt, Lauf funktioniert |
| NFA-03 | Keine festen Werte im Code: Schwellenwert, Stichtage, Startjahr, Höhenklassen und Vollständigkeitsgrenze stehen in `R/parameter.R` | Sensitivitätslauf ohne Codeänderung möglich |
| NFA-04 | Nachvollziehbarkeit: Jede Funktion hat einen Kommentar zu Zweck, Eingabe und Ausgabe; jede Kennzahl verweist auf ihre Definition in Kapitel 4 | Jedes Gruppenmitglied kann jede Funktion im Coachgespräch erklären |
| NFA-05 | Versionskontrolle mit Git | Git-Verlauf im Projekt vorhanden (ohne Commit-Kennung im Protokoll) |
| NFA-07 | Nur frei verfügbare Software: R und Pakete unter Open-Source-Lizenz | Paketliste mit Lizenz |
| NFA-09 | Robustheit: fehlende Datei, unbekannte Station oder falsches Spaltenformat führen zu einer klaren Fehlermeldung, nicht zu falschen Zahlen | Tests in Kapitel 8 |
| NFA-10 | Grafiken: Schrift in Druckgrösse lesbar, farbenblindtaugliche Palette, Achsen mit Einheit, deutsche Beschriftung, Quelle in der Legende der Arbeit | Probedruck schwarzweiss und farbig |
| NFA-11 | Quellenangabe pro Datensatz mit Bezugsdatum gespeichert | Datei mit Datenherkunft im Projekt |
| NFA-12 | KI-Protokoll: Wo KI beim Programmieren geholfen hat, ist mit Zweck und Umfang notiert | Tabelle für das KI-Verzeichnis im Anhang |

Vorschlag für die Ordnerstruktur, die NFA-01 bis NFA-03 stützt:

```
ski-ohne-schnee/
  daten/roh/          Originaldateien, unverändert
  daten/manuell/      stationen.csv, wirtschaft.csv
  daten/aufbereitet/  Tageswerte und Winterkennzahlen
  R/                  parameter.R (alle Parameter) und Funktionen
                      (einlesen, pruefen, kennzahlen, statistik, grafiken)
  tests/              Testfälle
  ausgabe/grafiken/   PDF und PNG
  ausgabe/tabellen/   CSV
  run_all.R           startet die ganze Kette
```

## 7 Ausgaben

Das Programm liefert zehn Grafiken und fünf Tabellen; welche davon in den Haupttext und welche in den Anhang kommen, entscheiden wir nach den ersten Resultaten.

| ID | Grafik | Aussage | Bezug |
|----|----|----|----|
| G1 | Zeitreihe Schneetage pro Station mit 100-Tage-Linie und Sen-Trendgerade | Entwicklung seit 1970 pro Station | TF1, H1 |
| G2 | Heatmap Station × Winter, Farbe = Schneetage, Stationen nach Höhe sortiert, ungültige Winter grau | Überblick über alle Stationen und Datenlücken | TF1 |
| G3 | Anteil schneesicherer Winter im gleitenden Zehnjahresfenster pro Station mit 70-%-Linie | Wann eine Station die Regel verliert | TF1 |
| G4 | Streudiagramm Anteil schneesicherer Winter gegen Stationshöhe, zwei Perioden, Gerade und Grenze bei 70 % | Verschiebung der Schneesicherheitsgrenze | TF2 |
| G5 | Dezember und April nebeneinander: Anteil Schneetage pro Winter mit Trend, nach Höhenklasse | Welcher Saisonrand stärker betroffen ist | TF3 |
| G6 | Sen-Steigung pro Station gegen Stationshöhe, signifikante Trends markiert | Höhenabhängigkeit des Trends | H1 |
| G7 | Streudiagramm-Matrix mit Korrelationskoeffizienten | Was womit zusammenhängt | Coachgespräch |
| G8 | Streudiagramm Schneetage gegen Betriebstage pro Bergbahn mit Regressionsgerade | Zusammenhang Schnee und Betrieb | H2, TF4 |
| G9 | Heatmap Skigebiet × Winter, Farbe = Betriebstage, hellrot bis dunkelrot | Darstellungsidee aus dem Coachgespräch | TF4 |
| G10 | Beschneiungsinvestitionen in Prozent des Umsatzes gegen Höhe des Gebiets | Höhenabhängigkeit der Beschneiung | H3 |

| ID | Tabelle | Inhalt |
|----|----|----|
| T1 | Stationsübersicht | Gebiet, Station, Höhe, Quelle, Messbeginn, Anzahl gültige Winter |
| T2 | Winterkennzahlen | Eine Zeile pro Station und Winter (Anhang) |
| T3 | Trendresultate | Station, Fenster, S, Z, p-Wert, Sen-Steigung pro Jahrzehnt, n |
| T4 | 100-Tage-Regel | Station, erfüllt in den ersten zehn Wintern ab Startwinter ja/nein, erfüllt in den letzten zehn Wintern ja/nein. Die Vergleichsperiode verschiebt sich im Sensitivitätslauf mit dem Startwinter |
| T5 | Sensitivität | Kernresultate für jede Kombination aus Saisonende und Startwinter |

Hinweis zu G9: Bei einer Skala von hell nach dunkel sollte dunkel für viele Betriebstage stehen, sonst liest man die Grafik verkehrt herum. Die Legende muss die Richtung klar zeigen.

## 8 Abnahmekriterien und Tests

Das Programm gilt als abgenommen, wenn alle Testfälle unten bestehen, ein Winter von Hand nachgezählt wurde und der Lauf auf einem zweiten Rechner dieselben Tabellen liefert.

Die Testfälle verwenden künstliche Daten, deren Ergebnis wir im Kopf oder von Hand kennen.

| ID | Testfall | Erwartetes Ergebnis | Prüft |
|----|----|----|----|
| TC-01 | Winter 1970/71, jeden Tag 30 cm | 136 Schneetage | K1, Grenze «mindestens» |
| TC-02 | Winter 1970/71, jeden Tag 29 cm | 0 Schneetage | K1 |
| TC-03 | Winter 1971/72 (Schaltjahr), jeden Tag 50 cm | 137 Schneetage | Schaltjahr |
| TC-04 | 100 cm nur am 30. November und am 16. April | 0 Schneetage | Fenstergrenzen |
| TC-05 | 100 cm nur am 1. Dezember und am 15. April | 2 Schneetage | Fenstergrenzen |
| TC-06 | Wie TC-01, Saisonende 30. April | 151 Schneetage | Parameter Saisonende |
| TC-07 | Wie TC-01, aber 10 Tage ohne Messwert | Vollständigkeit 126/136 = 92,6 %, gültig; Untergrenze 126, Obergrenze 136 | K2 |
| TC-08 | Wie TC-01, aber 20 Tage ohne Messwert | Vollständigkeit 85,3 %, ungültig | K2 |
| TC-09 | Zehn Winter, davon 7 mit 100 Schneetagen und 3 mit 99 | Fenster schneesicher | K3, K4 |
| TC-10 | Zehn Winter, davon 6 mit 100 Schneetagen und 4 mit 99 | Fenster nicht schneesicher | K4 |
| TC-11 | Reihe 1, 2, …, 10 | S = 45, Var = 125, Z = 44/√125 = 3,94, Sen-Steigung = 1 | K7 (Handrechnung zur Kontrolle des Pakets `trend`) |
| TC-12 | Reihe mit zehnmal dem gleichen Wert | S = 0, Sen-Steigung = 0, Ausgabe «kein Trend berechenbar» statt p-Wert, kein Abbruch | K7, Bindungen |
| TC-13 | Zwei Stationen: 1000 m mit Anteil 0,2 und 2000 m mit Anteil 1,0 | Grenze bei 1625 m | K5 |
| TC-14 | Datei mit fehlender Spalte oder unbekannter Station | Klare Fehlermeldung, kein Resultat | NFA-09 |
| TC-15 | Wirtschaftszeile ohne Quelle oder Seite | Fehlermeldung mit Zeilennummer | FA-22 |

Nachrechnung zu TC-11: Bei zehn steigenden Werten sind alle 10·9/2 = 45 Paare positiv, also S = 45. Var = 10·9·25/18 = 125. Z = (45 − 1)/√125 = 3,94. Zu TC-13: b = (1,0 − 0,2)/(2000 − 1000) = 0,0008 pro Meter, a = 0,2 − 0,0008·1000 = −0,6, h\* = (0,7 + 0,6)/0,0008 = 1625 m.

**Prüfungen an echten Daten**

- [ ] Einen Winter einer Station in Excel von Hand zählen und mit dem Programm vergleichen

- [ ] Mann-Kendall-Resultat einer Station mit einem bestehenden R-Paket gegenrechnen

- [ ] Richtung der Trends mit der Literatur vergleichen: Abnahme in tiefen Lagen, uneinheitlich über 2000 m (Matiu et al., 2021, S. 1353, 1358). Nur die Richtung ist vergleichbar, weil die Studie andere Kennzahlen verwendet

- [ ] Lauf auf einem zweiten Rechner, Tabellen T2 und T3 Zeile für Zeile vergleichen

- [ ] Probedruck aller Grafiken, die in den Haupttext kommen

## 9 Rückverfolgbarkeit

Jede Teilfrage und jede Hypothese ist durch mindestens eine Muss-Anforderung und eine Ausgabe abgedeckt; H2 und H3 lassen sich mit dem Programm allein aber nicht belegen.

| Ziel | Anforderungen | Ausgaben | Was das Programm nicht leistet |
|----|----|----|----|
| TF1: Gebiete mit erfüllter 100-Tage-Regel heute und in den 1970er-Jahren | FA-09, FA-10, FA-11 | G1, G2, G3, T4 | Aussage gilt für die Station, nicht für das ganze Skigebiet |
| TF2: Höhe der Schneesicherheitsgrenze heute | FA-12 | G4 | Bei fünf Stationen nur eine grobe Spanne |
| TF3: Dezember stärker betroffen als April | FA-13, FA-16 | G5, T3 | Der April endet im Standardfenster am 15.; späte Schmelze bleibt unsichtbar. Tiefe Stationen haben in der ersten Aprilhälfte oft 0 Schneetage (Bodeneffekt), hohe im Dezember oft das Maximum (Deckeneffekt); das Programm weist pro Station und Teilfenster den Anteil der Winter bei 0 und beim Maximum aus, der Vergleich ist vor allem in mittleren Lagen aussagekräftig |
| TF4: Wirkung auf Betriebstage, Umsatz, Beschneiungsinvestitionen | FA-22 bis FA-25, FA-18 | G8, G9, G10 | Zusammenhang, keine Ursache |
| H1: signifikante Abnahme unter 1500 m, keine oder schwächere über 2000 m | FA-14, FA-15, FA-16 | G1, G6, T3 | Deckeneffekt über 2000 m beachten (Kapitel 4) |
| H2: weniger Schneesicherheit wegen steigender Temperaturen, dadurch weniger Betriebstage | FA-18, FA-23 | G8 | Temperatur ist im Programm nicht enthalten; Beschneiung kann Betriebstage vom Naturschnee entkoppeln |
| H3: je tiefer, desto mehr Beschneiung und stärkerer Fixkostenanstieg | FA-18, FA-24 | G10 | Fixkosten nicht definiert; wenige Datenpunkte |
| Vorgaben Coachgespräch | FA-17, FA-24, FA-25 | G7, G9 |  |
| Offene methodische Entscheide | FA-07, FA-08, FA-19 | T5 |  |

Kritischer Punkt zu H2: Die Hypothese behauptet eine Kette aus drei Gliedern: Temperatur, Schneesicherheit, Betriebstage. Das Programm prüft nur das zweite und dritte Glied. Für das erste Glied müssen wir entweder Temperaturreihen der gleichen Stationen als zusätzliche Eingabe aufnehmen oder uns auf die Literatur stützen und das in der Methodik offenlegen. Dazu passt der Einwand von Abegg et al. (2021), dass eine Schneekennzahl kein direkter Wirtschaftlichkeitsindikator ist.

## 10 Offene Entscheide und Risiken

Zwei Entscheide blockieren das Programmieren: die definitive Stationsliste und das Datenformat des SLF. Alle anderen lassen sich dank der Parameter später treffen.

| Nr. | Offener Entscheid | Wie das Programm ihn stützt | Entscheiden bis |
|----|----|----|----|
| E1 | Definitive Skigebiete und Stationen | Dateninventar der MeteoSchweiz auswerten: Messbeginn und Lücken pro Kandidat | KW 46 |
| E2 | SLF-Daten: Format, Zugang, Lizenz | Einlesefunktion erst nach Klärung schreiben | KW 46 |
| E3 | Saisonende 15. April oder 30. April | Sensitivitätstabelle T5 | KW 50 |
| E4 | Startwinter 1970/71, 1971/72 oder 1975/76 | Sensitivitätstabelle T5 | KW 50 |
| E5 | Mindestvollständigkeit pro Winter und Regel für ungültige Winter im Fenster | Lauf mit 80 %, 90 %, 95 % | KW 50 |
| E6 | Definition Weihnachtstage | Parameter | KW 48 |
| E7 | Definition Fixkosten für H3 | Felder in wirtschaft.csv | KW 48 |
| E8 | Temperatur als zusätzliche Eingabe für H2 oder Literaturbeleg | Zusätzliche Einlesefunktion, falls ja | KW 48 |
| E9 | Braunwald als Fallbeispiel | Station und Bergbahn in die Listen aufnehmen, kein Mehraufwand im Code | KW 50 |
| E10 | Code im Anhang abdrucken oder als Ablage verlinken | Mit den Coaches klären | KW 50 |
| E11 | Februar oder April als Vergleichsfenster zu Dezember in Teilfrage 3 (Projektskizze: «Hochwinter im Februar», dieses Dokument: April); mit den Coaches klären | Vergleichsfenster als Parameter | KW 48 |

| Risiko | Folge | Gegenmassnahme |
|----|----|----|
| Datenlücke 1981–1997 bei MeteoSchweiz-Stationen (Matiu et al., 2021, S. 1347) | Zu wenig gültige Winter, Trend nicht berechenbar | Vollständigkeit vor der Stationswahl prüfen; SLF-Station als Ersatz |
| Station repräsentiert das Skigebiet schlecht (Höhe, Exposition, Distanz) | Kennzahl sagt wenig über die Pisten aus | Höhe und Distanz in T1 ausweisen, in der Methodenkritik offenlegen |
| Standortwechsel oder Wechsel der Messmethode an einer Station | Scheinbarer Trend | Stationsgeschichte in den Metadaten prüfen, im Feld bemerkung festhalten |
| Nur fünf Stationen | Regression über die Höhe und H3 statistisch schwach | Mehr Stationen aufnehmen, wenn der Aufwand nur im Einlesen liegt; Resultate als Tendenz formulieren |
| Geschäftsberichte lückenhaft oder ohne Betriebstage | TF4 und H2 nur für wenige Bergbahnen prüfbar | Früh sichten (vor KW 48); fehlende Zahlen im Interview erfragen |
| Beschneiung entkoppelt Betriebstage vom Naturschnee | Kein Zusammenhang in G8, obwohl der Schnee abnimmt | Als Ergebnis deuten, nicht als Fehler; Anteil beschneiter Pisten als erklärende Variable |
| Viele Tests an denselben Daten | Einzelne «signifikante» Resultate durch Zufall | Anzahl Tests ausweisen, Gesamtbild statt Einzelwert deuten |
| Zeit: Programm und erste Resultate laut Zeitplan bis KW 47 | Verzug bei Theorie und Geschäftsberichten | Zuerst nur Muss-Anforderungen bis FA-16 für zwei Stationen, dann ausbauen |

## 11 Arbeitspakete

Bis zum Coachgespräch in KW 50 müssen die Pakete AP1 bis AP6 fertig sein, damit wir Datengrundlage und Methodik mit echten Resultaten besprechen können.

| Paket | Inhalt | Anforderungen | Kalenderwoche |
|----|----|----|----|
| AP1 | Stationen wählen: Dateninventar auswerten, SLF-Zugang klären, stationen.csv anlegen | FA-04, E1, E2 | 46 |
| AP2 | Projektgerüst: Ordner, Git, R/parameter.R, run_all.R | NFA-01 bis NFA-05 | 46 |
| AP3 | Einlesen und Prüfen | FA-01 bis FA-07 | 46–47 |
| AP4 | Winterkennzahlen und Testfälle TC-01 bis TC-10 | FA-09 bis FA-14 | 47 |
| AP5 | Trendtest, Testfälle TC-11 bis TC-13, Grafiken G1 bis G6 | FA-16, FA-27 | 47–48 |
| AP6 | Sensitivitätslauf und Tabellen T1 bis T5 | FA-19, FA-28 | 48–49 |
| AP7 | Geschäftsberichte sichten und wirtschaft.csv erfassen | FA-22 | 48–50 |
| AP8 | Wirtschaftsauswertung und Grafiken G7 bis G10 | FA-17, FA-18, FA-23 bis FA-25 | 50–51 |
| AP9 | Soll-Anforderungen, Abnahme, Lauf auf zweitem Rechner, Probedruck | FA-08, FA-15, FA-29, Kapitel 8 | 51–1 |
| AP10 | Korrekturen nach dem Coachgespräch Rohfassung |  | 3 |

Abweichung vom Zeitplan der Projektskizze: Dort stehen Programm und erste Resultate bis KW 47. Mit dieser Aufteilung liegen die Schneeresultate (AP5) Ende KW 48 vor, eine Woche später. Entweder AP1 bis AP4 noch diese Woche beginnen oder den Verzug im Arbeitsjournal festhalten.

Offen: Wer übernimmt welches Paket? Sinnvoll ist, dass eine Person das Programm führt und eine zweite jede Funktion gegenliest, damit alle den Code erklären können.

## 12 Glossar

| Begriff | Bedeutung in diesem Dokument |
|----|----|
| Schneetag | Tag mit mindestens 30 cm gemessener Schneehöhe im Saisonfenster |
| Winter w | 1\. Dezember des Vorjahrs bis 15. April des Jahres w |
| Schneesicherer Winter | Winter mit mindestens 100 Schneetagen |
| 100-Tage-Regel | Station gilt als schneesicher, wenn mindestens 7 von 10 Wintern schneesicher sind |
| Schneesicherheitsgrenze | Höhe, ab der die 100-Tage-Regel erfüllt ist |
| Gültiger Winter | Winter, dessen Vollständigkeit die Mindestgrenze erreicht |
| Mann-Kendall-Test | Rangbasierter Test auf einen monotonen Trend in einer Zeitreihe |
| Sen-Steigung | Median aller paarweisen Steigungen; robuste Schätzung der Trendstärke |
| Bindungen | Gleiche Werte in einer Zeitreihe; sie verändern die Varianz der Teststatistik |
| Deckeneffekt | Eine Kennzahl kann ihr Maximum nicht überschreiten und zeigt deshalb keine Veränderung |
| Sensitivitätsanalyse | Wiederholung der Auswertung mit veränderten Annahmen, um die Stabilität der Resultate zu prüfen |
| OGD | Open Government Data, frei nutzbare Behördendaten |

## Quellen

- Abegg, B., Morin, S., Demiroglu, O. C., François, H., Rothleitner, M. & Strasser, U. (2021). Overloaded! Critical revision and a new conceptual approach for snow indicators in ski tourism. *International Journal of Biometeorology, 65*(5), 691–701. doi:10.1007/s00484-020-01867-3

- Marty, C., Schlögl, S., Bavay, M. & Lehning, M. (2017). How much can we save? Impact of different emission scenarios on future snow cover in the Alps. *The Cryosphere, 11*(1), 517–529. doi:10.5194/tc-11-517-2017

- Matiu, M., Crespi, A., Bertoldi, G., Carmagnola, C. M., Marty, C., Morin, S., … Weilguni, V. (2021). Observed snow depth trends in the European Alps: 1971 to 2019. *The Cryosphere, 15*(3), 1343–1382. doi:10.5194/tc-15-1343-2021

- MeteoSchweiz. (2026). [Manual precipitation stations. Open Data Documentation](https://opendatadocs.meteoswiss.ch/a-data-groundbased/a5-manual-precipitation-stations). Abgerufen am 11.11.2026

- MeteoSchweiz. (2026). [Automatic weather stations. Open Data Documentation](https://opendatadocs.meteoswiss.ch/a-data-groundbased/a1-automatic-weather-stations). Abgerufen am 11.11.2026

- Projektunterlagen: Projektskizze «Ski ohne Schnee?» (21.10.2026), Leistungsnachweis II, IDPA-Bewertungsraster schriftliche Arbeit, Leitfaden KI 2026

Die Seitenangaben zu Matiu et al. (2021) stammen aus unserem Leistungsnachweis II. Die Form der Internetquellen vor der Übernahme in die Arbeit mit dem Zitierleitfaden 2026 abgleichen.

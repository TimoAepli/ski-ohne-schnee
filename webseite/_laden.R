# _laden.R
# Zweck:   Gemeinsamer Start für alle Seiten der Webseite: lädt Parameter
#          und Funktionen aus dem Projektordner und liest die
#          Stationen und Tageswerte mit denselben Funktionen wie run_all.R.
# Eingabe: keine (wird zu Beginn jeder .qmd-Datei mit source() geladen)
# Ausgabe: Objekte parameter, stationen, tage im Arbeitsbereich
#
# Der Unterstrich am Anfang sagt Quarto, dass dies keine eigene Seite ist.

# Quarto führt den Code im Ordner webseite/ aus; R-Code und Daten liegen
# eine Ebene höher im Projektordner.
projekt <- normalizePath("..")

source(file.path(projekt, "R/parameter.R"), encoding = "UTF-8")
source(file.path(projekt, "R/einlesen.R"), encoding = "UTF-8")
source(file.path(projekt, "R/pruefen.R"), encoding = "UTF-8")
source(file.path(projekt, "R/grafiken.R"), encoding = "UTF-8")

stationen <- lies_stationen(file.path(projekt, "daten/manuell/stationen.csv"))
tage <- suppressMessages(
  lies_alle_stationen(stationen, file.path(projekt, "daten/roh/meteoschweiz"),
                      parameter))

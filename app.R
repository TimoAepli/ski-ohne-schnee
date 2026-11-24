# app.R
# Lokale Oberfläche zum Ansehen der Resultate (FA-31).
# Start in RStudio: diese Datei öffnen, oben auf «Run App» klicken.
# Start ohne RStudio, im Projektordner: Rscript -e "shiny::runApp()"
# Die öffentliche Webseite ist eine eigene, statische Quarto-Seite
# (Ordner webseite/); diese App läuft nur lokal.
#
# Die Oberfläche rechnet nichts Eigenes: Sie ruft dieselben Funktionen auf
# wie run_all.R und zeigt deren Ergebnis an.

library(shiny)

source("R/parameter.R", encoding = "UTF-8")
source("R/einlesen.R", encoding = "UTF-8")
source("R/pruefen.R", encoding = "UTF-8")
source("R/grafiken.R", encoding = "UTF-8")


# --- Daten einmal beim Start laden -------------------------------------------
# Geht dabei etwas schief (fehlende Datei, falsches Format), merken wir uns
# die Fehlermeldung und zeigen sie in jeder Registerkarte an.
ladefehler <- NULL
stationen <- NULL
tage <- NULL
tryCatch({
  stationen <- lies_stationen("daten/manuell/stationen.csv")
  tage <- lies_alle_stationen(stationen, "daten/roh/meteoschweiz", parameter)
}, error = function(e) {
  ladefehler <<- conditionMessage(e)
})

# Auswahlliste der Stationen: angezeigt wird «Name (Kürzel, Höhe)»,
# weitergegeben wird nur das Kürzel
if (is.null(ladefehler)) {
  stationsauswahl <- setNames(
    stationen$station_id,
    paste0(stationen$station_name, " (", stationen$station_id, ", ",
           stationen$hoehe_station_m, " m)"))
  # Zeitraum für den Schieberegler: vom ersten Jahr mit Messwert bis heute
  jahre_mit_wert <- as.integer(format(tage$datum[!is.na(tage$hs_cm)], "%Y"))
  erstes_jahr <- min(jahre_mit_wert)
  letztes_jahr <- max(jahre_mit_wert)
} else {
  stationsauswahl <- character(0)
  erstes_jahr <- parameter$start_winter - 1
  letztes_jahr <- as.integer(format(Sys.Date(), "%Y"))
}


# --- Aufbau der Seite ---------------------------------------------------------
ui <- fluidPage(
  titlePanel("Ski ohne Schnee? – Schneehöhen"),
  sidebarLayout(
    sidebarPanel(
      selectInput("station", "Station", choices = stationsauswahl),
      sliderInput("jahre", "Zeitraum (Kalenderjahre)",
                  min = erstes_jahr, max = letztes_jahr,
                  value = c(max(erstes_jahr, parameter$start_winter - 1),
                            letztes_jahr),
                  step = 1, sep = ""),
      numericInput("schwelle", "Hilfslinie Schneehöhe (cm)",
                   value = parameter$schwellenwert_cm, min = 0, step = 5),
      helpText("Die Hilfslinie dient nur zum Anschauen. Massgebend für die",
               "Kennzahlen ist der Schwellenwert in R/parameter.R."),
      width = 3
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Schneehöhe",
                 plotOutput("grafik_schneehoehe", height = "450px")),
        tabPanel("Datenlücken",
                 p("Tage mit und ohne Messwert von Dezember bis April,",
                   "pro Kalenderjahr."),
                 plotOutput("grafik_luecken", height = "300px"),
                 tableOutput("tabelle_luecken")),
        tabPanel("Auffälligkeiten",
                 p("Meldungen der Plausibilitätsprüfung. Obergrenze ",
                   parameter$pruef_obergrenze_cm, " cm, Tagessprung über ",
                   parameter$pruef_sprung_cm, " cm (aus R/parameter.R)."),
                 tableOutput("tabelle_auffaellig"))
      ),
      width = 9
    )
  )
)


# --- Verhalten der Seite -------------------------------------------------------
server <- function(input, output, session) {

  # Tageswerte der gewählten Station im gewählten Zeitraum.
  # reactive() rechnet neu, sobald Station oder Zeitraum ändern.
  auswahl <- reactive({
    validate(need(is.null(ladefehler), paste("Fehler beim Laden:", ladefehler)))
    req(input$station)
    jahr <- as.integer(format(tage$datum, "%Y"))
    filter(tage, station_id == input$station,
           jahr >= input$jahre[1], jahr <= input$jahre[2])
  })

  # Name der gewählten Station für die Überschriften
  stationsname <- reactive({
    zeile <- stationen[stationen$station_id == input$station, ]
    paste0(zeile$station_name, " (", zeile$station_id, ", ",
           zeile$hoehe_station_m, " m ü. M.)")
  })

  output$grafik_schneehoehe <- renderPlot({
    reihe <- auswahl()
    validate(need(any(!is.na(reihe$hs_cm)),
                  "Keine Messwerte im gewählten Zeitraum."))
    # Kurze Zeiträume brauchen eine feinere Jahresbeschriftung
    spanne <- input$jahre[2] - input$jahre[1]
    abstand <- if (spanne <= 10) "1 year" else if (spanne <= 30) "5 years" else "10 years"
    zeichne_schneehoehenreihe(reihe, paste("Schneehöhe", stationsname()),
                              achsenabstand = abstand) +
      geom_hline(yintercept = input$schwelle, linetype = "dashed",
                 colour = "grey30") +
      labs(subtitle = paste0("Orange Striche unten: Tage ohne Messwert. ",
                             "Gestrichelt: ", input$schwelle, " cm"))
  })

  # Übersicht der Lücken, einmal berechnet und von Grafik und Tabelle genutzt
  luecken <- reactive({
    datenuebersicht(auswahl(), parameter$uebersicht_monate)
  })

  output$grafik_luecken <- renderPlot({
    daten <- luecken()
    validate(need(nrow(daten) > 0, "Keine Tage im gewählten Zeitraum."))
    # Ohne Lücken wäre die Grafik leer; dann lieber eine klare Meldung
    validate(need(any(daten$tage_ohne_messwert > 0),
                  "Keine fehlenden Tage im gewählten Zeitraum."))
    zeichne_datenluecken(daten, paste("Tage ohne Messwert,", stationsname()))
  })

  output$tabelle_luecken <- renderTable({
    rename(luecken(), Jahr = jahr, `Tage mit Messwert` = tage_mit_messwert,
           `Tage ohne Messwert` = tage_ohne_messwert) |>
      select(-station_id)
  }, digits = 0)

  output$tabelle_auffaellig <- renderTable({
    meldungen <- pruefe_tageswerte(auswahl(), parameter$pruef_obergrenze_cm,
                                   parameter$pruef_sprung_cm)
    validate(need(nrow(meldungen) > 0,
                  "Keine Auffälligkeiten im gewählten Zeitraum."))
    # Datum als Text, sonst zeigt die Tabelle Tageszahlen statt Daten
    meldungen |>
      mutate(datum = format(datum, "%d.%m.%Y")) |>
      select(Datum = datum, `Schneehöhe (cm)` = hs_cm, Prüfung = pruefung,
             Detail = detail)
  }, digits = 0)
}

shinyApp(ui, server)

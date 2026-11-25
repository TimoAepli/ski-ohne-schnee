# statistik.R
# Trendtest K7 (Mann-Kendall und Sen-Steigung) gemäss Kapitel 4 der
# Anforderungsanalyse, FA-16. Gerechnet wird mit dem R-Paket `trend`,
# keine eigene Implementierung.

# Zweck:   Testet eine Zeitreihe (ein Wert pro Winter) auf einen monotonen
#          Trend: Mann-Kendall-Test mit Bindungskorrektur und Sen-Steigung.
#          Sonderfall Reihe ohne jede Veränderung (alle Werte gleich): Die
#          Varianz ist 0, Z nicht definiert. Dann S = 0, Steigung = 0, kein
#          p-Wert und Hinweis «kein Trend berechenbar», ohne Abbruch (TC-12).
# Eingabe: werte     Zahlen, ein Wert pro Winter, lückenlos und zeitlich
#                    sortiert, ohne NA (z. B. Schneetage der gültigen Winter)
#          parameter Liste aus parameter.R (signifikanzniveau)
# Ausgabe: Tabelle mit einer Zeile: n, s, var_s, z, p_wert,
#          sen_steigung (Einheit pro Winter), sen_steigung_jahrzehnt
#          (mal 10 Winter), signifikant (TRUE/FALSE/NA), hinweis
trendtest <- function(werte, parameter) {
  if (!is.numeric(werte)) {
    stop("Trendtest braucht Zahlen, erhalten: ", class(werte)[1], call. = FALSE)
  }
  if (anyNA(werte)) {
    stop("Trendtest: Reihe enthält NA. Fehlende Winter vorher klären ",
         "(offener Punkt: Umgang mit Lücken in der Reihe).", call. = FALSE)
  }
  if (length(werte) < 3) {
    stop("Trendtest braucht mindestens 3 Werte, erhalten: ", length(werte),
         call. = FALSE)
  }
  if (!requireNamespace("trend", quietly = TRUE)) {
    stop("R-Paket 'trend' fehlt: install.packages(\"trend\")", call. = FALSE)
  }

  n <- length(werte)
  if (length(unique(werte)) == 1) {
    return(tibble(n = n, s = 0, var_s = 0, z = NA_real_, p_wert = NA_real_,
                  sen_steigung = 0, sen_steigung_jahrzehnt = 0,
                  signifikant = NA, hinweis = "kein Trend berechenbar"))
  }

  mk  <- trend::mk.test(werte)       # Mann-Kendall mit Bindungskorrektur
  sen <- trend::sens.slope(werte)    # Median der paarweisen Steigungen
  steigung <- unname(sen$estimates)
  tibble(n = n,
         s = unname(mk$estimates["S"]),
         var_s = unname(mk$estimates["varS"]),
         z = unname(mk$statistic),
         p_wert = mk$p.value,
         sen_steigung = steigung,
         sen_steigung_jahrzehnt = steigung * 10,  # 10 Winter = 1 Jahrzehnt
         signifikant = mk$p.value < parameter$signifikanzniveau,
         hinweis = NA_character_)
}

library(leaflet)
library(leaflet.minicharts)
library(htmlwidgets)

source("velib.R")

city <- "Lyon"
velib_data <- get_velib_data(city)
last_update <- get_last_update(velib_data)

map <- leaflet(
  data = velib_data,
  options = leafletOptions(
    minZoom = 13,
    maxZoom = 17
  )
) |>
  addProviderTiles("CartoDB.DarkMatter") |>
  setView(lng = 4.85, lat = 45.76, zoom = 14) |>
  addMinicharts(
    lng = velib_data$lng,
    lat = velib_data$lat,
    type = "pie",
    chartdata = setNames(
      velib_data[, c("pct_free", "pct_occ", "pct_ko")],
      c("Free", "Occupied", "Out of order")
    ),
    colorPalette = c("green", "orange", "red"),
    width = 40,
    opacity = 0.6,
    popup = popupArgs(
      html = mapply(
                    function(name, n_free, n_occ, n_ko) {
                      icons <- c(rep("🚲", n_occ),
                                 rep("🅿️", n_free),
                                 rep("🚫", n_ko))
                      rows <- split(icons,
                                    ceiling(seq_along(icons) / 10))
                      grid <- paste(
                        vapply(rows, paste, character(1), collapse = ""),
                        collapse = "<br>"
                      )
                      paste0("<b>", name, "</b><br>", grid)
                    },
                    velib_data$name,
                    velib_data$n_free,
                    velib_data$n_occ,
                    velib_data$n_ko,
                    SIMPLIFY = TRUE, USE.NAMES = FALSE)
    )
  ) |>
  addControl(
    html = paste0(
      "<div style='background:rgba(0,0,0,0.65);color:#fff;padding:8px 14px;",
      "border-radius:5px;font-family:sans-serif;line-height:1.5;'>",
      "<strong>JCDecaux ", city, " &mdash; ",
      "Velov'</strong><br>",
      "<small>Updated: ", last_update, "</small>",
      "</div>"
    ),
    position = "topleft"
  )
saveWidget(map, "docs/index.html", selfcontained = FALSE)
message(sprintf("Map saved at %s", last_update))

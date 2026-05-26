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
    chartdata = velib_data[, c("pct_free", "pct_occ", "pct_ko")],
    colorPalette = c("green", "orange", "red"),
    width = 40,
    opacity = 0.6
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

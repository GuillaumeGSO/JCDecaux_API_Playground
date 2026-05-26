library(leaflet)
library(mapview)



make_map <- function(city, velib_data, last_update) {
  map <- leaflet(data = velib_data) |>
    addProviderTiles("CartoDB.DarkMatter") |>
    setView(lng = 4.85, lat = 45.76, zoom = 14) |>
    # Simple circle markers
    addCircleMarkers(
      lng = ~lng,
      lat = ~lat,
      radius = ~ sqrt(pct_max) * 2,
      color = ~color,
      fillOpacity = 0.5
    )

  mapshot(map,
    file = paste0("images/", city, "/", city, "_", last_update, ".jpg"),
    vwidth = 1280,
    vheight = 720,
    selfcontained = FALSE
  )
}

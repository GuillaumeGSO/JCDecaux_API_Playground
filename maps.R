make_map <- function(city, velib_data, last_update) {
  out_dir <- file.path("images", city)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  safe_stamp <- gsub(" ", "_", last_update)
  out_file <- file.path(out_dir, paste0(city, "_", safe_stamp, ".jpg"))

  map <- leaflet::leaflet(data = velib_data) |>
    leaflet::addProviderTiles("CartoDB.DarkMatter") |>
    leaflet::fitBounds(
      lng1 = quantile(velib_data$lng, 0.25, na.rm = TRUE, names = FALSE),
      lat1 = quantile(velib_data$lat, 0.25, na.rm = TRUE, names = FALSE),
      lng2 = quantile(velib_data$lng, 0.75, na.rm = TRUE, names = FALSE),
      lat2 = quantile(velib_data$lat, 0.75, na.rm = TRUE, names = FALSE)
    ) |>
    leaflet::addCircleMarkers(
      lng = ~lng,
      lat = ~lat,
      radius = ~ sqrt(pct_max) * 2,
      color = ~color,
      fillOpacity = 0.5
    )

  tryCatch(
    mapview::mapshot(
      map,
      file = out_file,
      vwidth = 1280,
      vheight = 720,
      selfcontained = FALSE
    ),
    error = function(e) {
      warning(
        "mapshot failed for ", city, " @ ", last_update, ": ",
        conditionMessage(e)
      )
    }
  )
}

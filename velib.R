library(jsonlite)


get_velib_data <- function(city) {
  api_key <- Sys.getenv("JCDECAUX_API_KEY")
  all_infos <- fromJSON(
    paste(
      "https://api.jcdecaux.com/vls/v1/stations?contract=",
      city,
      "&apiKey=", api_key,
      sep = ""
    )
  )

  place_free <- all_infos$available_bike_stands
  place_occ <- all_infos$available_bikes
  places <- all_infos$bike_stands
  pct_free <- (place_free / places * 100)
  pct_occ <- (place_occ / places * 100)
  pct_ko <- ((places - place_free - place_occ) / places * 100)

  pct_max <- pmax(pct_free, pct_occ, pct_ko)
  dominant <- apply(
    data.frame(pct_free, pct_occ, pct_ko), 1,
    function(x) names(which.max(x))
  )

  data.frame(
    stations = all_infos$number,
    name = all_infos$name,
    lng = all_infos$position$lng,
    lat = all_infos$position$lat,
    last_update = all_infos$last_update,
    pct_free,
    pct_occ,
    pct_ko,
    pct_max,
    dominant,
    color = unname(
      c(pct_free = "green", pct_occ = "orange", pct_ko = "red")[dominant]
    )
  )
}


get_last_update <- function(velib_data) {
  dt <- as.POSIXct(velib_data$last_update[[1]] / 1000, origin = "1970-01-01")
  format(dt, "%Y-%m-%d %Hh%M")
}

#Test
# v <- get_velib_data()
# head(v)
# str(v)
# get_last_update(v)

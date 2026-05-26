get_velib_data <- function(city) {
  api_key <- Sys.getenv("JCDECAUX_API_KEY")
  if (!nzchar(api_key)) {
    stop("JCDECAUX_API_KEY not set in .Renviron")
  }

  url <- sprintf(
    "https://api.jcdecaux.com/vls/v1/stations?contract=%s&apiKey=%s",
    utils::URLencode(city),
    api_key
  )

  all_infos <- tryCatch(
    jsonlite::fromJSON(url),
    error = function(e) {
      stop("JCDecaux fetch failed for ", city, ": ", conditionMessage(e))
    }
  )

  place_free <- all_infos$available_bike_stands
  place_occ  <- all_infos$available_bikes
  places     <- all_infos$bike_stands
  divisor    <- pmax(places, 1L)

  n_ko_raw <- places - place_free - place_occ
  pct_free <- place_free / divisor * 100
  pct_occ  <- place_occ  / divisor * 100
  pct_ko   <- pmax(0, n_ko_raw / divisor * 100)

  pct_mat  <- cbind(pct_free, pct_occ, pct_ko)
  pct_max  <- pmax(pct_free, pct_occ, pct_ko)
  dominant <- c("pct_free", "pct_occ", "pct_ko")[
    max.col(pct_mat, ties.method = "first")
  ]

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
    ),
    n_total = places,
    n_free  = place_free,
    n_occ   = place_occ,
    n_ko    = pmax(0L, n_ko_raw)
  )
}


get_last_update <- function(velib_data) {
  ts <- max(velib_data$last_update, na.rm = TRUE)
  dt <- as.POSIXct(ts / 1000, origin = "1970-01-01", tz = "Europe/Paris")
  format(dt, "%Y-%m-%d %Hh%M")
}

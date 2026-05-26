source("velib.R")
source("maps.R")

city <- "Lyon"
poll_interval <- 60
first_run <- TRUE

while (TRUE) {
  tryCatch({
    velib_data <- get_velib_data(city)
    new_update <- get_last_update(velib_data)
    if (first_run || new_update != last_update) {
      make_map(city, velib_data, new_update)
      last_update <- new_update
      first_run <- FALSE
      message(sprintf("Map updated at %s", last_update))
    } else {
      message(sprintf("No update, last update was at %s", last_update))
    }
  }, error = function(e) {
    message(sprintf("Error: %s", e$message))
  })
  Sys.sleep(poll_interval)
}

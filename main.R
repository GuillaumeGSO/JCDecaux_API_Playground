source("velib.R")
source("maps.R")

city <- "Lyon"
poll_interval <- 600

while (TRUE) {
  tryCatch({
    velib_data <- get_velib_data(city)
    last_update <- get_last_update(velib_data)
    make_map(city, velib_data, last_update)
    message(format(Sys.time(), "[%H:%M:%S]"), " Map saved for ", last_update)
  }, error = function(e) {
    message(format(Sys.time(), "[%H:%M:%S]"), " Error: ", conditionMessage(e))
  })
  Sys.sleep(poll_interval)
}

# This is a test file to test the geocoding of cities using OpenStreetMap API
library(jsonlite)
cities <- data.frame(
  nom = c(
    "Toulouse", "Paris", "Égletons", "Marseille",
    "Clermont Ferrand", "unable to find this city"
  ), pays = rep("FR", 6),
  effectif = c(20, 5, 15, 3, 3, 0)
)
print(cities)

locate_country <- function(name_city, code_country) {
  clean_city_name <- gsub(" ", "%20", name_city)
  url <- paste0(
    "http://nominatim.openstreetmap.org/search?city=",
    clean_city_name,
    "&countrycodes=",
    code_country,
    "&limit=9&format=json"
  )
  res_osm <- fromJSON(url)

  if (length(res_osm) > 0) {
    print(res_osm)
    c(res_osm$lon[1], res_osm$lat[1])
  }
  #default value if no result is found
  rep(NA, 2)

}

coord <- t(apply(cities, 1, function(row) {
  locate_country(row[1], row[2])
}))

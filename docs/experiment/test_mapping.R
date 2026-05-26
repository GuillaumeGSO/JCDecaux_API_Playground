library(jsonlite)
city <- "Lyon"
api_key <- Sys.getenv("JCDECAUX_API_KEY")
api_key

all_infos <- fromJSON(
  paste(
    "https://api.jcdecaux.com/vls/v1/stations?contract=",
    city,
    "&apiKey=", api_key,
    sep = ""
  )
)
# total bke stand : 40260
head(all_infos)
class(all_infos)
nrow(all_infos)
names(all_infos)
stations <- all_infos$number
placelibre <- all_infos$available_bike_stands
placeoccupe <- all_infos$available_bikes
places <- all_infos$bike_stands
lon <- all_infos$position["lng"]
lat <- all_infos$position["lat"]

head(lon)
head(lat)
mean(placelibre)
sum(placelibre)
mean(placeoccupe)
sum(placeoccupe)
mean(places)
sum(places)
class(all_infos)
class(all_infos$address)
pct_libre <- (placelibre / places * 100)
pct_occ <- (placeoccupe / places * 100)
pct_ko <- ((places - placelibre - placeoccupe) / places * 100)
pct_max <- pmax(pct_libre, pct_occ, pct_ko)

pct_libre + pct_occ + pct_ko

dominant <- apply(
  data.frame(pct_libre, pct_occ, pct_ko), 1,
  function(x) names(which.max(x))
)
dominant

color <- unname(
  c(pct_libre = "green", pct_occ = "orange", pct_ko = "red")[dominant]
)
color

c(pct_libre[1], pct_occ[1], pct_ko[1], pct_max[1], dominant[1], color[1])

all_infos$bike_stands[[1]]
all_infos$available_bike_stands[[1]]
all_infos$available_bikes[[1]]
all_infos$last_update[[1]]

df_velib_info <- data.frame(
  all_infos$name,
  all_infos$position["lng"],
  all_infos$position["lat"],
  pct_libre,
  pct_occ,
  pct_ko,
  pct_max,
  dominant,
  color
)
head(df_velib_info)

head(df_velib_info$lat)
head(df_velib_info$lng)

head(df_velib_info)

# install.packages("leaflet")

library(leaflet)
library(leaflet.minicharts)
# Paris : lon=2.34 lat=48.85
get_paris_map <- leaflet() |>
  addProviderTiles("CartoDB.DarkMatter") |>
  setView(lng = 2.34, lat = 48.85, zoom = 18)
get_paris_map

# Lyon : lon=4.83, lat=45.76
map <- leaflet(data = df_velib_info) |>
  # addTiles() |>
  addProviderTiles("CartoDB.DarkMatter") |>
  setView(lng = 4.85, lat = 45.76, zoom = 14) |>
  # Simple circle markers
  # addCircleMarkers(
  #   lng = ~lng,
  #   lat = ~lat,
  #   radius = ~ sqrt(pct_max) * 2,
  #   color = ~color,
  #   fillOpacity = 0.5
  # )
  addMinicharts(
    lng = df_velib_info$lng,
    lat = df_velib_info$lat,
    type = "pie",
    chartdata = df_velib_info[, c("pct_libre", "pct_occ", "pct_ko")],
    colorPalette = c("green", "orange", "red"),
    width = 30
  )


map

# Save a jpeg image of the map
# install.packages("mapview")
library(mapview)

# install.packages("webshot")
# webshot::install_phantomjs()


all_infos$last_update[[1]]
timestamp <- format(
  as.POSIXct(all_infos$last_update[[1]] / 1000,
    origin = "1970-01-01"
  ),
  "%Y-%m-%d_%H%M%S"
)
timestamp

mapshot(map,
  file = paste0("images/temp_", city, "/", city, "_", timestamp, ".jpg"),
  vwidth = 1024,
  vheight = 768,
  selfcontained = FALSE
)

# Velib Map

Polls the JCDecaux API at regular intervals and saves a snapshot map of bike-sharing station availability as a `.jpg` image.

Each station is drawn as a circle sized by its dominant occupancy percentage and colored by status:

- **Green** — bikes available
- **Orange** — docks available
- **Red** — station out of service

## Setup

1. Get a free API key from [JCDecaux Developer](https://developer.jcdecaux.com/)
2. Create a `.Renviron` file at the project root:

```
JCDECAUX_API_KEY=your_key_here
```

3. Install dependencies in R:

```r
install.packages(c("jsonlite", "leaflet", "mapview"))
```

4. Create the output folder for your city (e.g. Lyon):

```
mkdir -p images/Lyon
```

## Usage

```r
source("main.R")
```

The script polls every 60 seconds and saves a new map to `images/<city>/` whenever the API reports a new update.

To target a different city, edit the `city` variable in [main.R](main.R). Available cities can be listed via:

```
https://api.jcdecaux.com/vls/v1/contracts?apiKey=<YOUR_API_KEY>
```

> Note: Paris no longer uses JCDecaux.

## Files

| File | Description |
|------|-------------|
| `main.R` | Entry point — polling loop |
| `velib.R` | Fetches and parses station data from the API |
| `maps.R` | Renders and saves the leaflet map as an image |

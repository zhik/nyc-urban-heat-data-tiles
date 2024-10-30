# NYC Urban Heat Map Data Scripts

This repo contains scripts that maintains the data in s3 and supabase for the [NYC Urban Heat Map](https://github.com/BetaNYC/nyc-urban-heat).

## Data Types

Data is stored based on size and how often they need to be queried.

1. Downloads are generally are large files that do not need to be queried. These are stored in the `urban-heat-files s3 bucket`.
2. Dataset configuration files like [datasets.csv](https://github.com/BetaNYC/nyc-urban-heat/blob/main/public/datasets.csv) contain the locations of the downloads and map tiles, as well as the NTA data for the all the layers. This is small and queried often so it is stored with the app.
3. Weather station data is a large and needs to be queried by station or date to not overload the user. It is stored on the `supabase`. This allows for either queries via  [supabase's client libaries](https://supabase.com/docs/reference/javascript/start) or fetch request using [PostgREST](https://supabase.com/docs/guides/api).
4. Lastly map tiles are a usually a collection of files repeating x/y/zoom tiles of an area, or a large file/ database that needs to be query via server. To avoid this, we host a single pmtile per layer on `urban-heat-portal-tiles s3 bucket` that are cloud optimized to only serve the location. Read daniel-j-h's post on [Everything You Wanted to Know About Vector Tiles (But Were Afraid to Ask)](https://www.openstreetmap.org/user/daniel-j-h/diary/404061) and [Cloud-Optimized Geospatial Formats Guide](https://guide.cloudnativegeo.org/pmtiles/intro.html) for more details.

## Stucture

Following the outline above, this repo is organized into folders. First data is pulled from the internet or uses scripts from [mehdiheris/UrbanHeatDataAnalytic](https://github.com/mehdiheris/UrbanHeatDataAnalytics), then ETLs them into their respective storage mediums.

`analytic`: pulls data and runs UrbanHeatDataAnalytic in to the data folder

`_data`: stores the raw and processing data

`notebooks`: contains the interactive notebooks as a testing area for to process data and upload them to their respective storage mediums (ETLs).

`scripts`: the finalized ETL scripts packaged into libaries

`jobs`: bash scripts that run the timed automations

## Step up

Copy and fill out .env

```bash
cp .env.example .env
```

For data types 1-3 you can notebooks/scripts using your local machine's conda. For analytic scripts and script 4, you need use docker to install all the gdal and other dependencies.

### conda setup

```bash
conda create -n nyc-urban-heat -c conda-forge notebook sqlalchemy geopandas python-dotenv boto3 psycopg2 pyarrow
conda activate nyc-urban-heat
jupyter notebook
```

### docker setup

```bash
docker build . -t tile-generator-notebook
docker run -v ${PWD}:/app -p 8888:8888 -it tile-generator-notebook 

jupyter notebook --ip 0.0.0.0 --no-browser --allow-root
```

#### Other helpful commands and links

```bash
rio calc "(* 2.0 (read 1))" input.tif test.tif
rio mbtiles test.tif output.mbtiles --format PNG --zoom-levels 10..15 --tile-size 512 
pmtiles convert output.mbtiles output.pmtiles
```

[COG GeoTiff]( https://www.cogeo.org/developers-guide.html) are an alternative to hosting raster layers using pmtiles. https://github.com/geomatico/maplibre-cog-protocol

```bash
rio cogeo create input.tif input_jpeg.tif
rio cogeo create in.tif out.tif --cog-profile deflate
gdal_translate input.tif output.tif -of COG -co TILING_SCHEME=GoogleMapsCompatible -co COMPRESS=JPEG
```

## Adding data manually

### s3

### github

### supabase

tba

#!/usr/bin/env bash

export PGHOST=$POSTGRES_HOST
export PGDATABASE=$POSTGRES_DB
export PGUSER=$POSTGRES_USER

# Wait for postgresql
pg_isready
while [[ $? -ne 0 ]]
do
    pg_isready
    sleep 5
done

# Suppression du schéma et des données existantes et recréation
psql -c "DROP SCHEMA IF EXISTS $POSTGRES_SCHEMA CASCADE;"
psql -c "CREATE SCHEMA $POSTGRES_SCHEMA;"
psql -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# Download example tile from 3dbag (impersonate browser)
curl --compressed \
-A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:126.0) Gecko/20100101 Firefox/126.0" \
-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" \
-o tile.gpkg \
"https://data.3dbag.nl/v20240420/tiles/7/688/32/7-688-32.gpkg"

ls -alh

ogr2ogr -f "PostgreSQL" PG:"host=$PGHOST user=$PGUSER dbname=$PGDATABASE" -t_srs "EPSG:4979" tile.gpkg lod22_3d -nln sibbe

psql -c "CREATE INDEX ON sibbe USING gist(st_centroid(st_envelope(geom)))"

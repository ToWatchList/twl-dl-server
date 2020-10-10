#!/bin/sh
# test script, not for production use
set -x

# stop exiting docker containers
docker kill youtube-dl
docker rm youtube-dl
rm ./ytdl-test/*
rm ./ytdl-test/.*

docker build -t registry.local:5000/twl-dl-server -t twl-dl-server -t towatchlist/twl-dl-server .
docker push registry.local:5000/twl-dl-server
# docker push towatchlist/twl-dl-server

# localPath='/Volumes/Video/Other/ToWatchList'
localPath='/Users/nick/Documents/ToWatchList/twl-dl-server/ytdl-test'

docker run -d --name youtube-dl \
  -v ${localPath}:/youtube-dl \
  -p 8080:8080 \
  --env TWL_API_TOKEN=`cat .TWL_Token` \
  --env TWL_LOOKBACK_TIME_STRING=-3min \
  --env YDL_WRITE_NFO=True \
  --env KODI_URL='http://10.0.1.54:8080/jsonrpc' \
  twl-dl-server
docker ps
sleep 2

curl "http://localhost:8080/api/twl/update?TWL_LOOKBACK_TIME_STRING=-5hours"
# curl "http://uzfs.local:8085/api/twl/update"
open "http://localhost:8080/logs"

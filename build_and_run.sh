#!/bin/sh
# test script, not for production use

# stop exiting docker containers
docker kill youtube-dl
docker rm youtube-dl
rm  -rf ./ytdl-test/*
rm -rf ./ytdl-test/.*

set -xe

# multi arch build and push to local registry
# docker buildx build \
#   --output=type=registry,registry.insecure=true \
#   --platform linux/arm64,linux/amd64 \
#   -t registry.local:5000/twl-dl-server \
#   .
# docker pull registry.local:5000/twl-dl-server

docker build -t registry.local:5000/twl-dl-server .

# localPath='/Volumes/Video/Other/ToWatchList'
localPath='/Users/nick/Documents/ToWatchList/twl-dl-server/ytdl-test'

docker run -d --name youtube-dl \
  -v ${localPath}:/youtube-dl \
  -p 8080:8080 \
  --env TWL_API_TOKEN=`cat .TWL_Token` \
  --env TWL_LOOKBACK_TIME_STRING=-3min \
  --env YDL_WRITE_NFO=True \
  --env KODI_URL='http://10.0.1.54:8080/jsonrpc' \
  registry.local:5000/twl-dl-server
docker ps
sleep 2

curl "http://localhost:8080/api/twl/update?TWL_LOOKBACK_TIME_STRING=-30minutes"
# curl "http://uzfs.local:8085/api/twl/update"
open "http://localhost:8080/logs"

exit

# push to DockerHub registry
docker buildx build \
  --push \
  --platform linux/arm64,linux/amd64 \
  -t towatchlist/twl-dl-server \
  .

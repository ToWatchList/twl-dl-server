<!-- ![Docker Stars Shield](https://img.shields.io/docker/stars/nbr23/youtube-dl-server.svg?style=flat-square)
![Docker Pulls Shield](https://img.shields.io/docker/pulls/nbr23/youtube-dl-server.svg?style=flat-square)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://raw.githubusercontent.com/nbr23/youtube-dl-server/master/LICENSE) -->

# twl-dl-server

Simple Web and REST interface for downloading youtube videos onto a server. [`bottle`](https://github.com/bottlepy/bottle) + [`youtube-dl`](https://github.com/rg3/youtube-dl) /  / [`youtube-dl`](https://github.com/ytdl-org/youtube-dl). This TWL version adds integrations with [ToWatchList](https://towatchlist.com) and [Kodi](https://kodi.tv).

This project is forked from [nbr23/youtube-dl-server](https://github.com/nbr23/youtube-dl-server), which was previously forked from [manbearwiz/youtube-dl-server](https://github.com/manbearwiz/youtube-dl-server).

![screenshot][1]
![screenshot][2]

## Running

For easier deployment, a docker image is available on [dockerhub](https://hub.docker.com/r/towatchlist/twl-dl-server).

The `latest` image now uses youtube-dl. For the original youtube-dl based image, use `nbr23/youtube-dl-server:youtube-dl`

### Docker CLI

This example uses the docker run command to create the container to run the app. Note the `-v` argument to specify the volume and its binding on the host. This directory will be used to output the resulting videos.

```shell
docker run -d --name youtube-dl -v $HOME/youtube-dl:/youtube-dl towatchlist/twl-dl-server
```

### Docker Compose

This is an example service definition that could be put in `docker-compose.yml`.

```yml
  youtube-dl:
    image: "towatchlist/twl-dl-server"
    volumes:
      - $HOME/youtube-dl:/youtube-dl
    restart: always
```

The `latest` image now uses youtube-dl. For the original youtube-dl based image, use `nbr23/youtube-dl-server:youtube-dl`

#### Configuration
For easier configuration management and edition, you can save your variables in an external file and source them in your docker-compose.yml like the following example.

Configuration file `config.env`:

```
YDL_RECODE_VIDEO_FORMAT="webm"
YDL_SUBTITLES_LANGUAGES="en"
```

docker-compose.yml:
```yml
  youtube-dl:
    image: "towatchlist/twl-dl-server"
    env_file:
      - ./config.env
    volumes:
      - $HOME/youtube-dl:/youtube-dl
    restart: always
```

### Python

If you have python ^3.3.0 installed in your PATH you can simply run like this, providing optional environment variable overrides inline.

```shell
YDL_SERVER_PORT=8123 python3 -u ./youtube-dl-server.py
```

## Usage

### Start a download remotely

Downloads can be triggered by supplying the `{{url}}` of the requested video through the Web UI or through the REST interface via curl, etc.

#### HTML

Just navigate to `http://{{host}}:8080/` and enter the requested `{{url}}`.

#### Curl

```shell
curl -X POST --data-urlencode "url={{url}}" http://{{host}}:8080/api/downloads
```

#### Fetch

```javascript
fetch(`http://${host}:8080/api/downloads`, {
  method: "POST",
  body: new URLSearchParams({
    url: url,
    format: "bestvideo"
  }),
});
```

### Integration with ToWatchList

Add your account's API key from [ToWatchList Tools](https://towatchlist.com/tools) to the Docker's environment variables via the command line (or the Docker Compose). For example the command line could be:

```shell
docker run -d --name youtube-dl -v --env TWL_API_TOKEN=`${apitoken}` $HOME/youtube-dl:/youtube-dl towatchlist/twl-dl-server
```

You can trigger an update from TWL via a curl command, this can be added to external cron scripts too.

```shell
curl http://{{host}}:8080/api/twl/update
```

#### Bookmarklet

Add the following bookmarklet to your bookmark bar so you can conviently send the current page url to your youtube-dl-server instance.

##### HTTPS
If your youtube-dl-server is served through https (behind a reverse proxy handling https for example), you can use the following bookmarklet:

```javascript
javascript:fetch("https://${host}/api/downloads",{body:new URLSearchParams({url:window.location.href,format:"bestvideo"}),method:"POST"});
```

##### Plain text
If you are hosting it without HTTPS, the previous bookmarklet will likely be blocked by your browser (as it will generate mixed content when used on HTTPS sites).
Instead, you can use the following bookmarklet:

```javascript
javascript:(function(){document.body.innerHTML += '<form name="ydl_form" method="POST" action="http://${host}/api/downloads"><input name="url" type="url" value="'+window.location.href+'"/></form>';document.ydl_form.submit()})();
```

## Implementation

The server uses [`bottle`](https://github.com/bottlepy/bottle) for the web framework and [`youtube-dl`](https://github.com/rg3/youtube-dl) to handle the downloading. The integration with youtube-dl makes use of their [python api](https://github.com/rg3/youtube-dl#embedding-youtube-dl).

This docker image is based on [`python:alpine`](https://registry.hub.docker.com/_/python/) and consequently [`alpine:3.8`](https://hub.docker.com/_/alpine/).

[1]:https://github.com/ToWatchList/twl-dl-server/raw/main/youtube-dl-server.png
[2]:https://github.com/ToWatchList/twl-dl-server/raw/main/youtube-dl-server-logs.png

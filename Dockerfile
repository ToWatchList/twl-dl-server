FROM python:3.11-alpine

ARG YOUTUBE_DL=yt_dlp
ENV YOUTUBE_DL=$YOUTUBE_DL

RUN apk add --no-cache \
    ffmpeg \
    gcc \
    musl-dev \
    tzdata \
    unzip \
    wget && \
    python -m pip install --upgrade pip

WORKDIR /usr/src/app

COPY ./requirements.txt ./youtube-dl-server.py ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./ydl_server /usr/src/app/ydl_server

WORKDIR /usr/src/app/ydl_server/static

RUN wget -q https://code.jquery.com/jquery-3.4.1.min.js -O js/jquery.min.js && \
    wget -q https://unpkg.com/@popperjs/core@2.1.1/dist/umd/popper.min.js -O js/popper.min.js && \
    wget -q https://github.com/twbs/bootstrap/releases/download/v4.4.1/bootstrap-4.4.1-dist.zip && \
    mkdir tmp_bs && \
    unzip bootstrap-4.4.1-dist.zip -d tmp_bs && \
    mv tmp_bs/*/css/* css/ && \
    mv tmp_bs/*/js/* js/ && \
    rm -rf bootstrap-4.4.1-dist.zip tmp_bs && \
    apk del unzip

WORKDIR /usr/src/app

EXPOSE 8080

VOLUME ["/youtube-dl"]

CMD ["python", "-u", "./youtube-dl-server.py"]

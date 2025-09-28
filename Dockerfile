# Stage 1: Build Stage
FROM python:3.11-alpine as builder

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

WORKDIR /app

COPY ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./ydl_server /app/ydl_server
COPY ./youtube-dl-server.py /app/

WORKDIR /app/ydl_server/static

RUN wget -q https://code.jquery.com/jquery-3.4.1.min.js -O js/jquery.min.js && \
    wget -q https://unpkg.com/@popperjs/core@2.1.1/dist/umd/popper.min.js -O js/popper.min.js && \
    wget -q https://github.com/twbs/bootstrap/releases/download/v4.4.1/bootstrap-4.4.1-dist.zip && \
    mkdir tmp_bs && \
    unzip bootstrap-4.4.1-dist.zip -d tmp_bs && \
    mv tmp_bs/*/css/* css/ && \
    mv tmp_bs/*/js/* js/ && \
    rm -rf bootstrap-4.4.1-dist.zip tmp_bs && \
    apk del unzip

# Stage 2: Runtime Stage
FROM python:3.11-alpine

# Install only the necessary runtime dependencies
RUN apk add --no-cache \
    ffmpeg \
    tzdata

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/ydl_server /app/ydl_server
COPY --from=builder /app/youtube-dl-server.py /app/
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

EXPOSE 8080

VOLUME ["/youtube-dl"]

CMD ["python", "-u", "./youtube-dl-server.py"]

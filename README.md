# selenium-video
Python selenium recording controller to be used with pczerkas/standalone-chrome-debug

Docker image available at https://hub.docker.com/r/pczerkas/selenium-video

Start recording:<br/>
video_id=$(curl -XPOST http://192.168.1.1:9000/start -d '{"host":"selenium","display":"99","file_name":"test.mp4"}' |jq -r '.video_id')

Stop recording:<br/>
curl -v -XPOST http://192.168.1.1:9000/stop -d '{"video_id":"'"${video_id}"'"}'

Replace hosts and ports as configured in your infrastructure.

Docker-compose usage:

<pre>
selenium-video:
    image: pczerkas/selenium-video:1.0.0
    environment:
      - CONTROLLER_PORT=9000
      - MAX_MINUTES=3
    volumes:
      - ./some/path/to/videos:/videos
    healthcheck:
      test: /healthcheck.sh
      interval: 30s
      timeout: 10s
      retries: 1
      start_period: 20s
</pre>

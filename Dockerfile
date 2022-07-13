FROM jrottenberg/ffmpeg:4.3.1-ubuntu2004
LABEL authors="Selenium <selenium-developers@googlegroups.com>"
LABEL maintainer="Przemysław Czerkas <pczerkas@gmail.com>"

#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu focal main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu focal-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu focal-security main universe\n" >> /etc/apt/sources.list

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

#========================
# Supervisor
#========================
RUN apt-get -qqy update \
  && apt-get -qqy --no-install-recommends install \
    supervisor x11-xserver-utils python3-pip net-tools \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#======================================
# Add Supervisor configuration files
#======================================
COPY supervisord.conf /etc
COPY entry_point.sh controller.py /opt/bin/
COPY healthcheck.sh /
RUN chmod +x /opt/bin/entry_point.sh /healthcheck.sh
# RUN cd /opt/bin && pip install psutil

RUN  mkdir -p /var/run/supervisor /var/log/supervisor /videos

ENTRYPOINT ["/opt/bin/entry_point.sh"]
CMD ["/opt/bin/entry_point.sh"]

ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV FRAME_RATE 15
ENV CODEC libx264
ENV PRESET "-preset ultrafast"
ENV CONTROLLER_PORT 9000
ENV MAX_MINUTES 3

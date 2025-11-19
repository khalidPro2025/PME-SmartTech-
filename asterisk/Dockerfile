FROM debian:bullseye

# --------------------------------------------------
# Désactiver l'installation interactive + définir TZ
# --------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Dakar

# Fix timezone pour empêcher la demande interactive
RUN ln -fs /usr/share/zoneinfo/Africa/Dakar /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata

# --------------------------------------------------
# Installation d'Asterisk + outils
# --------------------------------------------------
RUN apt-get update && apt-get install -y \
    asterisk \
    asterisk-config \
    asterisk-core-sounds-fr \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Configuration Asterisk
# --------------------------------------------------
COPY sip.conf /etc/asterisk/
COPY extensions.conf /etc/asterisk/
COPY users.conf /etc/asterisk/

RUN chown asterisk:asterisk /etc/asterisk/*.conf && \
    chmod 644 /etc/asterisk/*.conf

# --------------------------------------------------
# Ports RTP + SIP
# --------------------------------------------------
EXPOSE 5060/udp 5060/tcp 10000-10100/udp

CMD ["/usr/sbin/asterisk", "-f"]

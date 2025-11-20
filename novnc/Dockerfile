FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Dakar

RUN apt-get update && apt-get install -y tzdata

# Install lightweight desktop
RUN apt-get update && apt-get install -y \
    python3-xdg \
    python3-gi \
    openbox \
    tint2 \
    xterm \
    x11vnc \
    novnc \
    websockify \
    xvfb \
    firefox \
    dbus-x11 \
    curl wget \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd

RUN mkdir -p /home/ubuntu/.vnc && \
    x11vnc -storepasswd "vncPass123!" /home/ubuntu/.vnc/passwd && \
    chown -R ubuntu:ubuntu /home/ubuntu/.vnc

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5900 6080

CMD ["/usr/local/bin/start.sh"]

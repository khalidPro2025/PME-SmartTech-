FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Dakar

RUN ln -fs /usr/share/zoneinfo/Africa/Dakar /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata

# --------------------------------------------------
# INSTALLATION COMPONENTS
# --------------------------------------------------
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    x11vnc \
    novnc \
    websockify \
    firefox \
    xvfb \
    dbus-x11 \
    net-tools \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# DISABLE UPOWER + POWER MANAGER
# --------------------------------------------------
RUN apt-get remove -y upower xfce4-power-manager || true

# --------------------------------------------------
# CREATE USER
# --------------------------------------------------
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    mkdir -p /shared && \
    chown ubuntu:ubuntu /home/ubuntu

# --------------------------------------------------
# VNC PASSWORD
# --------------------------------------------------
RUN mkdir -p /home/ubuntu/.vnc && \
    x11vnc -storepasswd "vncPass123!" /home/ubuntu/.vnc/passwd && \
    chown -R ubuntu:ubuntu /home/ubuntu/.vnc

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5900 6080

CMD ["/usr/local/bin/start.sh"]

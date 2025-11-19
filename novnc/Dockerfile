FROM ubuntu:22.04

# --------------------------------------------------
# Désactiver les interactions + définir le timezone
# --------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Dakar

# Fix timezone pour éviter les prompts bloquants
RUN ln -fs /usr/share/zoneinfo/Africa/Dakar /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata

# --------------------------------------------------
# Installation de l’environnement graphique + outils
# --------------------------------------------------
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    novnc \
    websockify \
    firefox \
    net-tools \
    iputils-ping \
    curl \
    wget \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Création de l’utilisateur
# --------------------------------------------------
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    mkdir -p /shared && \
    chown ubuntu:ubuntu /home/ubuntu

# --------------------------------------------------
# Configuration du mot de passe VNC
# --------------------------------------------------
RUN mkdir -p /home/ubuntu/.vnc && \
    x11vnc -storepasswd "vncPass123!" /home/ubuntu/.vnc/passwd && \
    chown -R ubuntu:ubuntu /home/ubuntu/.vnc

# --------------------------------------------------
# Script de démarrage
# --------------------------------------------------
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# --------------------------------------------------
# Ports
# --------------------------------------------------
EXPOSE 5900 6080

CMD ["/usr/local/bin/start.sh"]

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openssh-server \
    iputils-ping \
    net-tools \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash sshuser && \
    echo "sshuser:sshPass123!" | chpasswd && \
    mkdir -p /shared && \
    chown sshuser:sshuser /home/sshuser && \
    mkdir -p /var/run/sshd

# Allow password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

COPY sshd_config /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

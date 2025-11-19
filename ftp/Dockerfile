FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    vsftpd \
    iputils-ping \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ftpuser && \
    echo "ftpuser:ftpPass123!" | chpasswd && \
    mkdir -p /home/ftpuser/ftp /shared && \
    chown ftpuser:ftpuser /home/ftpuser/ftp && \
    chmod 755 /home/ftpuser/ftp

COPY vsftpd.conf /etc/vsftpd.conf
COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh && \
    chmod 755 /usr/local/bin/start.sh

EXPOSE 21 30000-30010

CMD ["/usr/local/bin/start.sh"]

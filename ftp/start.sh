#!/bin/bash

# Create FTP directory structure
mkdir -p /home/ftpuser/ftp/{upload,download,shared}
chown -R ftpuser:ftpuser /home/ftpuser/ftp
chmod -R 755 /home/ftpuser/ftp

# Create shared directory
mkdir -p /shared
chown ftpuser:ftpuser /shared
chmod 777 /shared

echo "Starting FTP Server..."
echo "FTP User: ftpuser"
echo "FTP Password: ftpPass123!"

# Start FTP server
exec /usr/sbin/vsftpd /etc/vsftpd.conf

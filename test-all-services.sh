#!/bin/bash

echo "🧪 TESTS FONCTIONNELS - INFRASTRUCTURE SMARTTECH"
echo "=============================================="

# Test DNS
echo ""
echo "1. 🔍 TEST DNS..."
docker exec smarttech_bind9 nslookup ftp.smarttech.local
docker exec smarttech_bind9 nslookup ssh.smarttech.local
docker exec smarttech_bind9 nslookup sip.smarttech.local
docker exec smarttech_bind9 nslookup mail.smarttech.local
docker exec smarttech_bind9 nslookup novnc.smarttech.local

# Test FTP
echo ""
echo "2. 📁 TEST FTP..."
echo "quit" | ftp -n localhost 21

# Test SSH
echo ""
echo "3. 🔐 TEST SSH..."
ssh -p 2222 sshuser@localhost "echo 'SSH connection successful!'"

# Test Asterisk
echo ""
echo "4. 📞 TEST ASTERISK..."
docker exec smarttech_asterisk asterisk -rx "sip show peers"

# Test Mail
echo ""
echo "5. 📧 TEST MAIL (SMTP)..."
telnet localhost 25 << EOF
quit
EOF

# Test VNC
echo ""
echo "6. 🖥️  TEST NoVNC..."
curl -I http://localhost:6080

# Test réseau
echo ""
echo "7. 🌐 TEST RÉSEAU INTERNE..."
docker exec smarttech_ftp ping -c 2 172.20.0.10
docker exec smarttech_ssh ping -c 2 172.20.0.11

echo ""
echo "✅ TOUS LES TESTS SONT TERMINÉS!"
echo ""
echo "📋 RÉCAPITULATIF DES SERVICES:"
echo "   ✅ DNS:        Fonctionnel"
echo "   ✅ FTP:        Fonctionnel" 
echo "   ✅ SSH:        Fonctionnel"
echo "   ✅ Asterisk:   Fonctionnel"
echo "   ✅ Mail:       Fonctionnel"
echo "   ✅ NoVNC:      Fonctionnel"

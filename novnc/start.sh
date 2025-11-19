#!/bin/bash

# Set up display
export DISPLAY=:1

# Start Xfce session
Xvfb :1 -screen 0 1280x720x16 &
sleep 2

# Start desktop environment
startxfce4 &

# Start VNC server
x11vnc -display :1 -forever -shared -bg -usepw -rfbport 5900 -noxdamage &

# Start noVNC
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "VNC/NoVNC Server Started"
echo "NoVNC URL: http://localhost:6080/vnc.html"
echo "VNC Password: vncPass123!"

# Keep container running
tail -f /dev/null
